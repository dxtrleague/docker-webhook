FROM golang:alpine3.12 AS builder
WORKDIR /go/src/github.com/adnanh/webhook
ENV WEBHOOK_VERSION 2.8.0
RUN apk add --update -t build-deps curl libc-dev gcc libgcc
RUN curl -L --silent -o webhook.tar.gz https://github.com/adnanh/webhook/archive/${WEBHOOK_VERSION}.tar.gz && \
    tar -xzf webhook.tar.gz --strip 1 &&  \
    go get -d && \
    go build -o /usr/local/bin/webhook && \
    apk del --purge build-deps && \
    rm -rf /var/cache/apk/* && \
    rm -rf /go

FROM alpine:3.12
LABEL author="DexterLeague" email="dexterleague62@gmail.com"
ENV HUGO_VERSION 0.79.1
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit


RUN apk add --update \
    tar \
    curl \
    git \
    bash \
    libstdc++ \
    libc6-compat \
#    g++ <- one day if we are having a problem with hugo, uncomment this (install package) and rebuild docker image 
    && rm -rf /var/cache/apk/*

RUN curl -SL https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}.tar.gz \
    -o /tmp/hugo.tar.gz \
    && tar -xzf /tmp/hugo.tar.gz -C /tmp \
    && mv /tmp/hugo /usr/local/bin/ \
    && rm -rf /tmp/* \
    && hugo version

# ENV WEBHOOK_VERSION 2.8.0
# RUN curl -SL https://github.com/adnanh/webhook/releases/download/${WEBHOOK_VERSION}/webhook-linux-amd64.tar.gz \
#     -o /tmp/webhook.tar.gz \
#     && tar -xzf /tmp/webhook.tar.gz -C /tmp \
#     && mv /tmp/webhook-linux-amd64/webhook /usr/local/bin/

COPY --from=builder /usr/local/bin/webhook /usr/local/bin/webhook
WORKDIR /etc/webhook
VOLUME ["/etc/webhook"]
EXPOSE 9000
ENTRYPOINT  ["webhook"]
