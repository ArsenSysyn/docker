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
## Dockerfile - app