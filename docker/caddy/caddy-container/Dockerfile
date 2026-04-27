# Build stage: build Caddy with extra plugins
FROM caddy:builder AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

# Final stage: use official Caddy base and copy custom binary
FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
