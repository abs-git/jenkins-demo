FROM nvidia/cuda:11.6.2-base-ubuntu20.04 AS base

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul

WORKDIR /code

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends openssh-client cmake vim wget curl git iputils-ping net-tools htop build-essential \
    python3.8 python3-pip && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 1 && \
    update-alternatives --set python3 /usr/bin/python3.8 && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir torch==1.12.1+cu116 torchvision==0.13.1+cu116 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu116
RUN pip3 install --no-cache-dir nvidia-pyindex==1.0.9
RUN pip3 install --no-cache-dir nvidia-tensorrt==8.4.1.5

COPY . /code

CMD ["/bin/sh", "-ec", "while :; do echo 'pxd running'; sleep 5; done"]
