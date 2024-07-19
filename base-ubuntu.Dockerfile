FROM ubuntu:20.04
LABEL maintainer="Sasha Gerrand <github+docker-glibc-builder@sgerrand.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV HTTP_PROXY=""
ENV HTTPS_PROXY=""

RUN sed -i 's@archive.ubuntu.com@mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@security.ubuntu.com@mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list


ENV DEBIAN_FRONTEND=noninteractive \
    GLIBC_VERSION=2.34 \
    PREFIX_DIR=/usr/glibc-compat
RUN apt-get -q update \
	&& apt-get -qy install \
		bison \
		build-essential \
		gawk \
		gettext \
		openssl \
		python3 \
		texinfo \
		wget
COPY configparams /glibc-build/configparams
COPY builder /builder
ENTRYPOINT ["/builder"]