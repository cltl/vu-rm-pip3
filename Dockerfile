FROM python:3.6

WORKDIR /vu-rm

RUN apt-get update && apt-get install -y \
    bash \
    gcc \
    libxslt-dev \
    openjdk-8-jdk \
    git \
    tcl \
    tk \
    maven \
    unzip \
    timbl \
    gawk

COPY . /vu-rm
RUN pip install -r ./env/requirements.txt
RUN bash ./install.sh && ls -l 

ENV ALPINO_HOME=/vu-rm/components/resources/Alpino
ENV PATH=$PATH:/vu-rm/components/resources/Alpino/bin

ENTRYPOINT ["./run-pipeline-dkr.sh"]
