# Build adguard sync
FROM golang:1.26.1-alpine AS builder

RUN go install github.com/bakito/adguardhome-sync@latest 

FROM alpine:latest

# Install all components
RUN apk add --no-cache \
    unbound \
    bird \
    supervisor \
    gettext \
    iproute2 \
    bash \
    ca-certificates \
    curl

# Download and install adguard home
RUN curl -Lfs -o /tmp/adguardhome.tar.gz https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz \
    && tar -xzf /tmp/adguardhome.tar.gz -C /tmp/ \
    && mv /tmp/AdGuardHome/AdGuardHome /usr/bin/adguardhome \
    && rm /tmp/adguardhome.tar.gz

RUN chmod +x /usr/bin/adguardhome


# Copy the adguardhome-sync binary from the builder stage
COPY --from=builder /go/bin/adguardhome-sync /usr/bin/adguardhome-sync
RUN chmod +x /usr/bin/adguardhome-sync

# Create directories for configs and data
RUN mkdir -p /etc/bird /etc/unbound /opt/adguardhome/conf /opt/adguardhome/work /var/log/supervisor

# Copy configuration templates
COPY config/unbound.conf /etc/unbound/unbound.conf
COPY config/bird.conf /etc/bird/bird.conf.template
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf.template
COPY entrypoint.sh /entrypoint.sh

# Set permissions
RUN chmod +x /entrypoint.sh

# We run in host mode, so ports are handled by the host network
ENTRYPOINT ["/entrypoint.sh"]