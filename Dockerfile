FROM semaphoreui/semaphore:v2.9.1
ARG S6_OVERLAY_VERSION=3.1.5.0
ARG TAILSCALE_VERSION=1.48.1

USER root

RUN apk update && apk upgrade
RUN apk add --no-cache wget bash iptables 

# install s6 overlay
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then ARCHITECTURE=x86_64; elif [ "$TARGETARCH" = "arm" ]; then ARCHITECTURE=arm; elif [ "$TARGETARCH" = "arm/v7" ]; then ARCHITECTURE=arm; elif [ "$TARGETARCH" = "arm/v6" ]; then ARCHITECTURE=armhf; elif [ "$TARGETARCH" = "arm64" ]; then ARCHITECTURE=aarch64; else ARCHITECTURE=x86_64; fi \
    && echo "Architecture: $ARCHITECTURE" \
    && echo "Downloading v${S6_OVERLAY_VERSION}/s6-overlay-${ARCHITECTURE}.tar.xz" \   
    && wget "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${ARCHITECTURE}.tar.xz" -O "/tmp/s6-overlay-${ARCHITECTURE}.tar.xz" \
    && tar -Jxpf "/tmp/s6-overlay-${ARCHITECTURE}.tar.xz" -C / \
    && rm -rf "/tmp/s6-overlay-${ARCHITECTURE}.tar.xz" \
    && wget "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" -O "/tmp/s6-overlay-noarch.tar.xz" \
    && tar -Jxpf "/tmp/s6-overlay-noarch.tar.xz" -C / \
    && rm -rf "/tmp/s6-overlay-noarch.tar.xz"
ENTRYPOINT ["/init"]
CMD []

COPY root/ /

# install tailscale static binaries, semaphore alpine included version is old
RUN wget "https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}.tgz" -O "/tmp/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}.tgz" \
    && tar -xvf "/tmp/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}.tgz" -C /tmp \
    && mv "/tmp/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}/tailscaled" /usr/bin/tailscaled \
    && mv "/tmp/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}/tailscale" /usr/bin/tailscale \
    && chmod +x /usr/bin/tailscaled \
    && chmod +x /usr/bin/tailscale \
    && rm -rf "/tmp/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}.tgz" \
    && rm -rf "/tmp/tailscale_${TAILSCALE_VERSION}_${TARGETARCH}"
