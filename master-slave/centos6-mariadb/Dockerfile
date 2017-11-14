FROM centos:6.8

RUN yum install -y epel-release &&yum update -y
# not using gnutls-devel as version too low by default, need 3.3.24+
RUN yum install -y git cmake make bison gcc gcc-c++ \
        libaio-devel ncurses-devel openssl-devel jemalloc
RUN git clone --depth=1 https://github.com/MariaDB/server.git
RUN cd /server && cmake .  -DBUILD_CONFIG=mysql_release -DRPM=centos6
RUN cd /server && make install

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
        && curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64" \
        && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.2/gosu-amd64.asc" \
        && gpg --verify /usr/local/bin/gosu.asc \
        && rm /usr/local/bin/gosu.asc \
        && rm -r /root/.gnupg/ \
        && chmod +x /usr/local/bin/gosu
RUN groupadd -r mysql && useradd -r -g mysql mysql
COPY entrypoint.sh /usr/local/bin/
EXPOSE 3306
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mysqld"]

