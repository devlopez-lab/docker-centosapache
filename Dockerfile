FROM centos:7

LABEL Description="Linux + Apache 2.4 + PHP 5.4. CentOS 7 based. Includes .htaccess support and popular PHP5 features, including mail() function." \
       License="Apache License 2.0" \
       Usage="docker run -d -p [HOST PORT NUMBER]:80 -v [HOST WWW DOCUMENT ROOT]:/var/www/html fauria/lap" \
       Version="1.0"

RUN yum -y update && yum clean all
RUN yum -y install httpd && yum clean all
RUN yum -y install net-tools nano wget vim ncdu sudo
RUN yum -y install gcc php-pear php-devel make openssl-devel && yum clean all
RUN yum install -y \
       psmisc \
       httpd \
       postfix \
       php \
       php-common \
       php-dba \
       php-gd \
       php-intl \
       php-ldap \
       php-mbstring \
       php-mysqlnd \
       php-odbc \
       php-pdo \
       php-pecl-memcache \
       php-pgsql \
       php-pspell \
       php-recode \
       php-snmp \
       php-soap \
       php-xml \
       php-xmlrpc \
       ImageMagick \
       ImageMagick-devel

RUN sh -c 'printf "\n" | pecl install mongo imagick'
RUN sh -c 'echo short_open_tag=On >> /etc/php.ini'
RUN sh -c 'echo extension=mongo.so >> /etc/php.ini'
RUN sh -c 'echo extension=imagick.so >> /etc/php.ini'

ENV LOG_STDOUT **Boolean**
ENV LOG_STDERR **Boolean**
ENV LOG_LEVEL warn
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE UTC

COPY resources/run-lap.sh /usr/sbin/
RUN chmod +x /usr/sbin/run-lap.sh

# Install MariaDB
COPY resources/MariaDB.repo /etc/yum.repos.d/MariaDB.repo
RUN yum clean all;yum -y install mariadb-server mariadb-client

COPY resources/supervisord.conf /etc/supervisord.conf

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in ; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done);
RUN rm -rf /lib/systemd/system/multi-user.target.wants/;
RUN rm -rf /etc/systemd/system/.wants/;
RUN rm -rf /lib/systemd/system/local-fs.target.wants/;
RUN rm -rf /lib/systemd/system/sockets.target.wants/udev;
RUN rm -rf /lib/systemd/system/sockets.target.wants/initctl;
RUN rm -rf /lib/systemd/system/basic.target.wants/;
RUN rm -rf /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ “/sys/fs/cgroup” ]

EXPOSE 80 443

CMD ["/usr/sbin/run-lap.sh"]
CMD ["/usr/sbin/init"]