FROM ghcr.io/void-linux/void-linux:latest-full-x86_64-musl
RUN xbps-install -Sy openssh tini bash iproute2 ncurses-base && \
        rm -rf /var/cache/xbps /etc/runit/runsvdir/default/* && \
        mkdir -p /run/runit && \
        ln -s /etc/sv/sshd /etc/runit/runsvdir/default
COPY entrypoint.sh /entrypoint
ENTRYPOINT ["/entrypoint"]
