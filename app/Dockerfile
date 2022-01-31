FROM centos:7

ADD entrypoint.sh /
ADD gerrit.war /var/gerrit/bin/gerrit.war

RUN yum -y install initscripts && \
    yum -y install java-11-openjdk && \
    yum -y install git  && \
    yum -y install openssh-server && \
    /entrypoint.sh init && \
    rm -f /var/gerrit/etc/{ssh,secure}* && rm -Rf /var/gerrit/{static,index,logs,data,index,cache,git,db,tmp}/* && \
    yum -y clean all

ENV CANONICAL_WEB_URL=
ENV HTTPD_LISTEN_URL=

# Allow incoming traffic
EXPOSE 29418 8080

VOLUME ["/var/gerrit/bin","/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]

ENTRYPOINT ["/bin/bash","/entrypoint.sh"]
