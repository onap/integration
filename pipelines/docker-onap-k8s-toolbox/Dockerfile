FROM alpine:latest

ARG KUBECTL_VERSION="v1.28.4"
ARG KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

ARG HELM_VERSION="v3.10.3"
ARG HELM_ARCHIVE="helm-${HELM_VERSION}-linux-amd64.tar.gz"
ARG HELM_URL="https://get.helm.sh/${HELM_ARCHIVE}"

WORKDIR /root

RUN apk add --no-cache git curl \
    && curl -L $KUBECTL_URL -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && curl -L $HELM_URL -o $HELM_ARCHIVE \
    && tar -zxf ${HELM_ARCHIVE} \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && rm -rf linux-amd64 $HELM_ARCHIVE

CMD ["/bin/sh"]