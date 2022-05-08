FROM ghcr.io/void-linux/void-linux:latest-full-x86_64-musl
RUN xbps-install -Sy tini bash bird iproute2 wireguard-tools && \
        rm -rf /var/cache/xbps /etc/runit/runsvdir/default/* && \
        mkdir -p /run/runit && \
        ln -sf /etc/runit/runsvdir/current /var/service && \
        rm -f /var/service/* && \
        ln -s /etc/sv/bird /var/service/ && \
        ln -s /data/peer0.conf /etc/wireguard/peer0.conf
COPY entrypoint.sh /entrypoint
ENTRYPOINT ["/entrypoint"]
