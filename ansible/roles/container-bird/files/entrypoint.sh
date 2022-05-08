#!/bin/sh

ln -sf /data/bird.conf /etc/bird.conf
wg-quick up peer0
exec /usr/bin/tini /usr/bin/runsvdir /var/service
