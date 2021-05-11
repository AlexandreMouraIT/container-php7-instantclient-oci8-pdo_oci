FROM oraclelinux:7.9

COPY files_oracle/* files_php/* ./opt/oracle/

RUN yum update -y && \
    yum upgrade -y && yum groupinstall "development tools" -y && \
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y && \
    yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum install yum-utils systemtap-sdt-devel -y libaio libaio-devel && \
    yum-config-manager --enable remi-php74 -y && \
    yum update -y  && \
    cd /opt/oracle/ && \
    tar -xvf php-7.4.19.tar.gz && \
    yum install httpd -y && \
    yum install php php-devel php-cli php-common php-pdo php-json php-xml php-pear php-imap php-zip php-curl php-gd php-dom php-hash php-phar -y && \
    rpm -ivh oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm && \
    rpm -ivh oracle-instantclient19.6-devel-19.6.0.0.0-1.x86_64.rpm && \
    echo "/usr/lib/oracle/19.6/client64/lib" >/etc/ld.so.conf.d/oracle.conf && ldconfig && \
    export ORACLE_HOME=/usr/lib/oracle/19.6/client64/ && \
    cd /opt/oracle/php-7.4.19/ext/oci8/ && \
    export PHP_DTRACE=yes && \
    phpize && ./configure --with-oci8=instantclient,/usr/lib/oracle/19.6/client64/lib && make install && \
    echo "extension=oci8.so" > /etc/php.d/oci8.ini && \
    cd /opt/oracle/php-7.4.19/ext/pdo_oci/ && \
    phpize && ./configure --with-pdo-oci=instantclient,/usr/lib/oracle/19.6/client64/lib && make install && \ 
    echo "extension=pdo_oci.so" > /etc/php.d/pdo_oci.ini && \
    cd /opt/oracle && \
    rm -f oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm oracle-instantclient19.6-devel-19.6.0.0.0-1.x86_64.rpm && \
    rm -f php-7.4.19.tar.gz && \
    yum clean all -y
   
VOLUME /var/www/html/

WORKDIR /var/www/html/

EXPOSE 80 443

ENTRYPOINT  ["/usr/sbin/httpd"]

CMD ["-D", "FOREGROUND"]

