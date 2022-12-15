#!/bin/sh
# Copyright (c) 2022 Bellrock Technology Ltd All rights reserved.
# See LICENCE file for details.

TS_AUTH_KEY="${TS_AUTH_KEY:-}"
HOSTNAME="${HOSTNAME:-}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
PIDS=""

TS_ARGS="--socket=/tmp/tailscaled.sock"

if [[ ! -d /dev/net ]]; then
  mkdir -p /dev/net
fi

if [[ ! -c /dev/net/tun ]]; then
  mknod /dev/net/tun c 10 200
fi

tailscaled ${TS_ARGS} &
PIDS="$PIDS $!"

TS_UP_ARGS="--accept-dns=true"
if [[ ! -z "${TS_AUTH_KEY}" ]]; then
  TS_UP_ARGS="${TS_UP_ARGS} --auth-key=${TS_AUTH_KEY}"
fi

if [[ ! -z "${HOSTNAME}" ]]; then
  TS_UP_ARGS="${TS_UP_ARGS} --hostname=${HOSTNAME}"
fi

if [[ ! -z "${EXTRA_ARGS}" ]]; then
  TS_UP_ARGS="${TS_UP_ARGS} ${EXTRA_ARGS}"
fi

tailscale --socket=/tmp/tailscaled.sock up ${TS_UP_ARGS}

coredns -conf /Corefile &
PIDS="$PIDS $!"

for pid in $PIDS; do
  wait $pid || let "DONE=1"
done

if ["$DONE" -eq 1]; then
  exit 1
fi
