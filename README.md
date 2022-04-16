# Docker build and run a Gerrit applicaton

For build, test and deploy Gerrit application we use docker containers and docker-compose for more comfortable work with its.
And all pipeline for CI is defained in __Jenkinsfile__.

---
## Dockerfile - build

##### Dockerfile
So there you can see a Dockerfile for creating our build image based on __centos:7__ image.
```
FROM centos:7

WORKDIR /app

COPY . .

RUN yum install curl git zip unzip maven python3 java-11-openjdk-devel -y && \
    curl -fsSL https://rpm.nodesource.com/setup_17.x | bash - && \
    yum install nodejs -y && \
    yum install gcc-c++ make -y && \
    npm install -g bower @bazel/bazelisk && \
    yum remove java-1.8.0-openjdk-devel -y && \
    yum clean all -y

VOLUME ["/root/.cache/bazel/_bazel_root"]

CMD ["/bin/bash", "/app/entrypoint.sh"]
```

##### Work directory and install necessary tools

As a work directory we use __/app__ directory which is storing in our repository and copy from them an __entrypoint.sh__ script as an entrypoint step in our image. And the `RUN` step for installing all necessary tools for build. 
##### Entrypoint
There you can see an __entrypoint.sh__ script there
```
#!/bin/bash

git clone --recurse-submodules https://gerrit.googlesource.com/gerrit
cd gerrit && bazel build :release
```
There are some few commands - for cloning repository with application code including submodules and start build application using bazel tool(tool for building and testing code powered by Google).
##### Volume
And also you can see a volume `VOLUME ["/root/.cache/bazel/_bazel_root"]` it is using for storing build-cache. But we need it? Because bazel for building code using cache and it rebuild only these things which were changed, so it reduce build and test time.

---

## Dockerfile - app

##### Dockerfile
So there you can see a Dockerfile for creating our application image based on __centos:7__ image.
```
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

VOLUME ["/var/gerrit/git", "/var/gerrit/index", "/var/gerrit/cache", "/var/gerrit/db", "/var/gerrit/etc"]

ENTRYPOINT ["/bin/bash","/entrypoint.sh"]
```
##### Work directory and install necessary tools

As a work directory we use __/app__ directory which is storing in our repository and copy from them an __entrypoint.sh__ script as an entrypoint step in our image. And the `RUN` step for installing all necessary tools for succesful running Gerrit application. 
##### Entrypoint
There you can see an __entrypoint.sh__ script there
```
#!/bin/bash -e

export JAVA_OPTS='--add-opens java.base/java.net=ALL-UNNAMED --add-opens java.base/java.lang.invoke=ALL-UNNAMED'

if [ ! -d /var/gerrit/git/All-Projects.git ] || [ "$1" == "init" ]
then
  echo "Initializing Gerrit site ..."
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war init --batch --dev -d /var/gerrit
  java $JAVA_OPTS -jar /var/gerrit/bin/gerrit.war reindex -d /var/gerrit
  git config -f /var/gerrit/etc/gerrit.config --add auth.type "DEVELOPMENT_BECOME_ANY_ACCOUNT"
fi

git config -f /var/gerrit/etc/gerrit.config gerrit.canonicalWebUrl "$CANONICAL_WEB_URL"
if [ "$1" != "init" ]
then
  echo "Running Gerrit ..."
  exec /var/gerrit/bin/gerrit.sh run
fi

```
These commands are using for initialization our application and configuring some necessary options. And the final step - run the application.
##### Expose
And the `EXPOSE 29418 8080` command are necessary for accessing to our application, __8080__ - for WEB UI, __29418__ - for SSH actions with application.
##### Volume
And also you can see a volumes
```
VOLUME ["/var/gerrit/git", 
        "/var/gerrit/index", 
        "/var/gerrit/cache", 
        "/var/gerrit/db", 
        "/var/gerrit/etc"]
```
These volumes are needed for storing all application data.

---

## Docker-compose
So for more comfortable work with multiple containers we use docker-compose tool. And there you can see a __docker-compose.yml__
```
version: "3.7"

services:
   bazel_build:
     build:
        context: ./build
     image: bazel_build
     volumes:
        - bazel_cache:/root/.cache/bazel/_bazel_root
   
   app:
     build: 
        context: ./app 
     image: application 
     volumes:
        - git:/var/gerrit/git
        - etc:/var/gerrit/etc
        - db:/var/gerrit/db
        - index:/var/gerrit/index
        - cache:/var/gerrit/cache
     ports:
        - 8080:8080
        - 29418:29418

volumes:
   bazel_cache:
   git:
   etc:
   db:
   index:
   cache:

```
So there you can see two services - __bazel_build__ and __app__, it have all necessary options like working directories, name of future images which will be created using `docker-compose build app/bazel_build` command from our Dockerfiles, volumes for storing data, and ports for accessing to application. 

_P.S. docker-compose command we run in our Jenkins_

---

## Jenkinsfile