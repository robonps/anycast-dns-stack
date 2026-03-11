#!/bin/bash
set -e

# 1. Create the Anycast Interface
echo "Initializing anycast0 with ${ANYCAST_IP}..."
ip link add anycast0 type dummy || true
ip addr add ${ANYCAST_IP}/32 dev anycast0 || true
ip link set anycast0 up

# 2. Inject Variables into the baked config
# We read the .raw file and write the real bird.conf
envsubst < /etc/bird/bird.conf.raw > /etc/bird/bird.conf
envsubst < /etc/supervisor/conf.d/supervisord.conf.template > /etc/supervisor/conf.d/supervisord.conf

# 3. Hand off to Supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf