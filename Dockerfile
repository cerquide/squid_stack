FROM ubuntu/squid:latest

# Install additional utilities
RUN apt-get update && apt-get install -y \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /etc/squid/certs /var/spool/squid /var/log/squid /var/lib/squid/ssl_db

# Copy Squid configuration
COPY squid.conf /etc/squid/squid.conf

# Generate self-signed SSL certificate for optional SSL bump
RUN openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -keyout /etc/squid/certs/squidCA.pem \
    -out /etc/squid/certs/squidCA.pem \
    -subj "/CN=Squid Proxy CA/O=Squid Proxy/C=US"

# Set proper permissions
RUN chown -R proxy:proxy /var/spool/squid /var/log/squid /etc/squid /var/lib/squid || \
    chown -R squid:squid /var/spool/squid /var/log/squid /etc/squid /var/lib/squid || \
    true

# Initialize cache directories
RUN squid -z -N 2>&1 | grep -v "Creating missing" || true

# Expose standard Squid proxy port
EXPOSE 3128

# Expose optional SSL bump port (uncomment if using SSL inspection)
# EXPOSE 3129

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD squid -k check || exit 1

# Run Squid in foreground
CMD ["squid", "-N"]
