FROM python:3.6-alpine3.9
MAINTAINER reach4avik@yahoo.com
LABEL maintainer="avikdatta"

ENTRYPOINT []

ENV NB_USER vmuser
ENV NB_GROUP vmuser
ENV NB_UID 1000
ENV FLASK_APP igftools.py
ENV FLASK_CONFIG production

USER root
WORKDIR /root/

RUN echo "http://alpinelinux.mirror.iweb.com/v3.9/main" >> /etc/apk/repositories; \
    echo "http://alpinelinux.mirror.iweb.com/v3.9/community" >> /etc/apk/repositories; \
    echo "http://alpinelinux.mirror.iweb.com/edge/testing" >> /etc/apk/repositories

RUN apk update && \
    apk add --upgrade apk-tools && \
    apk --update add --no-cache --force-broken-world \
        gcc \
        g++ \
        .build-deps \
        build-base \
        libbz2-dev \
        libopenblas-dev \
        libreadline6 \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        locales \
        texlive-xetex \
        zlib1g-dev 
        
      
RUN apk add --no-cache --force-broken-world \
    git                    \
    locales                \
    curl                   \
    wget                   \
    make                   \
    g++                    \
    patch                  \
    build-essential        \
    libssl-dev             \
    zlib1g-dev             \
    libbz2-dev             \
    libsqlite3-dev         \
    libssl-dev             \
    libreadline6           \
    libopenblas-dev        \
    openssl                \
    ca-certificates       \
    bash

RUN pip install --no-cache-dir  -q \
      numpy==1.17.2

RUN pip install --no-cache-dir  -q \
      pandas==0.24.1 \
      jinja2 \
      gviz_api \
      jsonschema \
      flask \
      flask_bootstrap4 \
      flask_wtf \
      gunicorn \
      paramiko==2.4.2

RUN addgroup -S $NB_GROUP && adduser -S -G $NB_GROUP $NB_USER

USER $NB_USER
WORKDIR /home/$NB_USER

RUN mkdir -p /home/$NB_USER/tmp
ENV TMPDIR=/home/$NB_USER/tmp


RUN git clone https://github.com/imperial-genomics-facility/data-management-python.git && \
    cd data-management-python && \
    git checkout metadata_201908 && \
    cd ~ && \
    git clone https://github.com/imperial-genomics-facility/Metadata_validation.git && \
    cd Metadata_validation && \
    git checkout v2 && \
    cd ~

RUN rm -rf /home/$NB_USER/tmp
RUN mkdir -p /home/$NB_USER/tmp

ENV PYTHONPATH=/home/$NB_USER/data-management-python:/home/$NB_USER/Metadata_validation:${PYTHONPATH}
ENV FLASK_INSTANCE_PATH=/home/$NB_USER/tmp
ENV SAMPLESHEET_SCHEMA=/home/$NB_USER/data-management-python/data/validation_schema/samplesheet_validation.json
ENV METADATA_SCHEMA=/home/$NB_USER/data-management-python/data/validation_schema/metadata_validation.json
ENV HOSTNAME=0.0.0.0

WORKDIR /home/$NB_USER/Metadata_validation
CMD gunicorn -d $HOSTNAME:$PORT igftools:app
