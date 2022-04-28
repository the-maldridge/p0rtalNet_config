#!/bin/sh

for f in passwd group shadow ; do
    ln -sf /etc/ssh/auth/$f /etc/$f
done

exec /usr/bin/tini /usr/bin/runsvdir /etc/runit/runsvdir/current
