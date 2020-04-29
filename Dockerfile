FROM python:3.6-slim-stretch

WORKDIR /vurm
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1 \
    && apt-get update && apt-get install -y \
        bash \
        g++ \
        gawk \
        git \
        libxslt-dev \
        lsof \
        make \
        maven \
        openjdk-8-jdk \
        tcl \
        timbl \
        tk \
        wget \
        unzip \
    && rm -rf /var/lib/apt/lists/*

COPY . /vurm
RUN pip install -r ./cfg/requirements.txt \
    && bash ./scripts/install.sh \
    && rm -rf /tmp/* 

ENTRYPOINT ["./scripts/run-pipeline-dkr.sh"]
