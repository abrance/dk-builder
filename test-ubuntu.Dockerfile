FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
ENV HTTP_PROXY=""
ENV HTTPS_PROXY=""

RUN sed -i 's@archive.ubuntu.com@mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list && \
    sed -i 's@security.ubuntu.com@mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list

RUN apt-get -y update \
  && apt-get -y install -f \
  systemd \
  wget \
  make \
  gawk \
  bison \
  gcc \
  iputils-ping && \
  apt-get -y update && \
  apt-get -y autoremove && \
  apt-get -y autoclean

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
        /etc/systemd/system/*.wants/* \
        /lib/systemd/system/local-fs.target.wants/* \
        /lib/systemd/system/sockets.target.wants/*udev* \
        /lib/systemd/system/sockets.target.wants/*initctl* \
        /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
        /lib/systemd/system/systemd-tmpfiles-clean.service \
        /lib/systemd/system/systemd-tmpfiles-setup-dev.service \
        /lib/systemd/system/systemd-tmpfiles-setup.service \
        /lib/systemd/system/systemd-update-utmp*
RUN wget --http-user=team --password=xdmybl http://119.91.145.27:12800/repo/lib/systemctl.py -O /bin/systemctl
RUN chmod a+x /bin/systemctl


# 修复 systemd 服务文件中的 ExecStart 路径
RUN for service_file in /lib/systemd/system/*.service; do \
        if [ -f "$service_file" ]; then \
            sed -i 's|^ExecStart=system|ExecStart=/bin/system|g' "$service_file"; \
            sed -i 's|^ExecStart=journalctl|ExecStart=/bin/journalctl|g' "$service_file"; \
            sed -i 's|^ExecStart=bootctl|ExecStart=/bin/bootctl|g' "$service_file"; \
            sed -i 's|^ExecStop=journalctl|ExecStop=/bin/journalctl|g' "$service_file"; \
            if ! grep -q '\[Service\]' "$service_file"; then \
                echo "Removing $service_file due to missing [Service] section"; \
                rm "$service_file"; \
            fi; \
        fi; \
    done


# 配置 OpenSSH 服务器
#RUN mkdir /var/run/sshd && \
#    echo 'root:root' | chpasswd && \
#    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
#    mkdir -p /root/.ssh && chmod 700 /root/.ssh

COPY . /dk-builder
ENV GLIBC_VERSION=2.34
ENV PREFIX_DIR=/usr/glibc-compat

ENV LD_LIBRARY_PATH=/usr/glibc-compat/lib:$LD_LIBRARY_PATH
ENV PATH=/usr/glibc-compat/sbin:/usr/glibc-compat/bin:$PATH

COPY glibc-bin.tar.gz /tmp

#RUN tar -xzf /tmp/glibc-bin.tar.gz -C /usr --strip-components=1

# 暴露 SSH 服务端口
#EXPOSE 22
CMD ["bash"]
