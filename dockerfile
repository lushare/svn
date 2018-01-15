FROM centos
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && yum -y install wget python-setuptools && easy_install pip && pip install supervisor && yum clean all
RUN yum -y install httpd httpd-devel mod_dav_svn mod_ssl apr-util-mysql mariadb-libs mariadb mariadb-devel patch gcc && yum clean all
RUN wget https://nchc.dl.sourceforge.net/project/modauthmysql/modauthmysql/3.0.0/mod_auth_mysql-3.0.0.tar.gz && wget https://sourceforge.net/p/modauthmysql/patches/13/attachment/mod_auth_mysql_3.0.0_patch_apache2.4.diff && tar zxf mod_auth_mysql-3.0.0.tar.gz && rm -rf mod_auth_mysql-3.0.0.tar.gz && cd mod_auth_mysql-3.0.0 && patch mod_auth_mysql.c -fp0 -i ../mod_auth_mysql_3.0.0_patch_apache2.4.diff && apxs -c -L/usr/lib64/mysql -I/usr/include/mysql -lmysqlclient -lm -lz mod_auth_mysql.c && apxs -i mod_auth_mysql.la && rm -rf ../mod_auth_mysql_3.0.0_patch_apache2.4.diff
RUN sed  -i 's#Options Indexes FollowSymLinks#Options FollowSymLinks#g' /etc/httpd/conf/httpd.conf && echo -e "ServerTokens Prod\nServerSignature off\nTraceEnable off">>/etc/httpd/conf/httpd.conf
COPY 10-subversion.conf /etc/httpd/conf.modules.d/10-subversion.conf
EXPOSE 80 443
CMD /usr/sbin/httpd &&  tail -F /var/log/httpd/ssl_access_log
