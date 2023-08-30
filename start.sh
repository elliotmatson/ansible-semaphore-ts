#!/bin/ash

cleanup() {
    echo "Cleaning up..."
    until tailscale logout; do
        sleep 0.1
    done
    kill -TERM ${PID}
    wait ${PID}
    exit 1
}

trap cleanup INT TERM

echo "Starting Tailscale daemon"
tailscaled --tun=userspace-networking --statedir=/var/lib/tailscale_state/ &
PID=$!

echo "Starting Tailscale"
until tailscale up --authkey="${TAILSCALE_AUTH_KEY}" --hostname="${TAILSCALE_HOSTNAME}"; do
    sleep 0.1
done
tailscale status
wait ${PID}
