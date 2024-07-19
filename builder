#!/usr/bin/env bash

set -eo pipefail; [[ "$TRACE" ]] && set -x

main() {
  GLIBC_VERSION=2.34
  PREFIX_DIR=/usr/glibc-compat
  declare version="${1:-$GLIBC_VERSION}" prefix="${2:-$PREFIX_DIR}"

  : "${version:?}" "${prefix:?}"
  # 备份并清除 LD_LIBRARY_PATH 环境变量
  OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
  unset LD_LIBRARY_PATH
  {
    # 下载 glibc 源代码并解压
    wget -qO- "http://ftp.gnu.org/gnu/glibc/glibc-$version.tar.gz" \
      | tar zxf - || { echo "Failed to download or extract glibc-$version.tar.gz"; exit 1; }

    # 创建构建目录并进入
    mkdir -p /glibc-build && cd /glibc-build
    mv /dk-builder/glibc-$version /
    # 配置构建参数
    "/glibc-$version/configure" \
      --prefix="$prefix" \
      --libdir="$prefix/lib" \
      --libexecdir="$prefix/lib" \
      --enable-multi-arch \
      --enable-stack-protector=strong || { echo "Failed to configure glibc-$version"; exit 1; }

    # 构建并安装
    make --jobs=4 && make install || { echo "Failed to build or install glibc-$version"; exit 1; }

    # 打包结果
    tar --dereference --hard-dereference -zcf "/glibc-bin-$version.tar.gz" "$prefix" || { echo "Failed to create tar.gz"; exit 1; }
  } >&2


  # 恢复 LD_LIBRARY_PATH 环境变量
  export LD_LIBRARY_PATH=$OLD_LD_LIBRARY_PATH

  # 输出结果
  [[ $STDOUT ]] && cat "/glibc-bin-$version.tar.gz"
}

main "$@"