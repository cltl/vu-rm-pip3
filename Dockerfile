FROM ubuntu:xenial as builder
WORKDIR /install
COPY install.sh .
COPY scripts/ ./scripts
ENV JAVA_TOOL_OPTIONS=-Dfile.encoding=UTF8
RUN apt-get update && apt-get install -y \
    git \
    maven \
    openjdk-8-jdk \
    make \
    g++ \
    wget \
    unzip
RUN bash ./install.sh 

FROM openjdk:8-jre-slim
COPY . /vu-rm
WORKDIR /vu-rm
COPY --from=builder /install/components ./components
RUN apt-get update && apt-get install -y \
    tcl \
    tk \
    timbl \
    gawk \
    lsof \
    python3 \
    python3-pip \
    && rm -rf /var/cache/apt/lists/* \
    && ln -sf /usr/bin/pip3 /usr/bin/pip \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && python -m pip install --upgrade pip \
    && pip install -r env/requirements.txt \
    && echo "export ALPINO_HOME=/vu-rm/components/resources/Alpino" > .newsreader 

ENTRYPOINT ["./run-pipeline-dkr.sh"]
