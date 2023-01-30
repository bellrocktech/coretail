FROM golang:1.19-alpine AS build

WORKDIR /go/src/coredns

RUN apk add git make && \
    git clone --depth 1 --branch=v1.9.1 https://github.com/coredns/coredns /go/src/coredns && cd plugin && \
    git clone https://github.com/coredns/alternate && \
    sed -i s/forward:forward/alternate:github.com\\/coredns\\/alternate\\nforward:forward/ /go/src/coredns/plugin.cfg && \
    cat /go/src/coredns/plugin.cfg && \
    cd .. && \
    make check && \
    go install

FROM ghcr.io/tailscale/tailscale:v1.34.2 AS tailscale

FROM alpine:3.17
RUN apk add --no-cache ca-certificates iptables iproute2 ip6tables

COPY --from=tailscale /usr/local/bin/tailscale /usr/local/bin/
COPY --from=tailscale /usr/local/bin/tailscaled /usr/local/bin/
COPY --from=build /go/bin/coredns /usr/local/bin/

COPY run.sh Corefile /

ENTRYPOINT ["/run.sh"]
