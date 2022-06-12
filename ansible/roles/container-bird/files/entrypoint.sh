#!/bin/sh

ln -sf /data/bird.conf /etc/bird.conf
ln -sf /data/wg/* /etc/wireguard/
for tun in /etc/wireguard/*.conf ; do
    wg-quick up $tun
done
exec /usr/bin/tini /usr/bin/runsvdir /var/service
