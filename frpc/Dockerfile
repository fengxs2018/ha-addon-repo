ARG BUILD_FROM
FROM ${BUILD_FROM}

ARG FRP_VERSION=0.71.0
ARG BUILD_ARCH=amd64

RUN apk add --no-cache bash ca-certificates jq tar tzdata curl

# 按架构下载官方 frpc 二进制
RUN set -eux; \
    case "${BUILD_ARCH}" in \
        amd64)   FRP_ARCH="amd64" ;; \
        i386)    FRP_ARCH="386" ;; \
        aarch64) FRP_ARCH="arm64" ;; \
        armv7)   FRP_ARCH="arm" ;; \
        armhf)   FRP_ARCH="arm" ;; \
        *)       FRP_ARCH="${BUILD_ARCH}" ;; \
    esac; \
    url="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz"; \
    echo "下载 ${url}"; \
    curl -fsSL "${url}" -o /tmp/frp.tar.gz; \
    tar -xzf /tmp/frp.tar.gz -C /tmp; \
    install -m 0755 "/tmp/frp_${FRP_VERSION}_linux_${FRP_ARCH}/frpc" /usr/bin/frpc; \
    rm -rf /tmp/frp.tar.gz "/tmp/frp_${FRP_VERSION}_linux_${FRP_ARCH}"; \
    frpc --version

COPY run.sh /run.sh
RUN chmod 0755 /run.sh

CMD [ "/run.sh" ]
