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
