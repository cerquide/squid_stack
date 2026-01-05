# Squid Forward Proxy

A Squid forward proxy with HTTPS support, containerized with Docker and ready for Komodo deployment. Configure this proxy in your browser to route internet traffic through it.

## Overview

This project provides a Squid forward proxy that you can configure in your browser to:
- Route all HTTP and HTTPS traffic through the proxy
- Cache frequently accessed content for improved performance
- Control and monitor web access
- Optionally inspect HTTPS traffic (with SSL bump enabled)

## Prerequisites

- Docker
- Docker Compose
- (Optional) Komodo for deployment management

## Quick Start

### Build and run the proxy

```bash
docker compose up --build -d
```

The proxy will be available at `localhost:3128`

### Stop the proxy

```bash
docker compose down
```

## Browser Configuration

Configure your browser to use the proxy server:

### Chrome / Edge

1. Open Settings
2. Navigate to System → Open your computer's proxy settings
3. Enable Manual proxy configuration
4. Set HTTP Proxy: `localhost` Port: `3128`
5. Set HTTPS Proxy: `localhost` Port: `3128`
6. Save settings

Alternatively in Chrome:
1. Settings → System → Open your computer's proxy settings
2. Or use command line: `chrome --proxy-server="localhost:3128"`

### Firefox

1. Open Settings (Preferences)
2. Scroll to Network Settings → Settings button
3. Select Manual proxy configuration
4. HTTP Proxy: `localhost` Port: `3128`
5. Check "Also use this proxy for HTTPS"
6. Click OK

### Safari (macOS)

1. System Preferences → Network
2. Select your active network connection
3. Click Advanced → Proxies tab
4. Check "Web Proxy (HTTP)" and "Secure Web Proxy (HTTPS)"
5. Enter Server: `localhost` Port: `3128` for both
6. Click OK → Apply

### Command Line / Environment Variables

Set these environment variables to use the proxy system-wide:

```bash
export http_proxy="http://localhost:3128"
export https_proxy="http://localhost:3128"
export HTTP_PROXY="http://localhost:3128"
export HTTPS_PROXY="http://localhost:3128"
```

## SSL Certificate Trust (Optional)

If you enable SSL bump on port 3129 for HTTPS inspection, you'll need to trust the proxy's CA certificate.

### Export the certificate

```bash
docker cp squid_proxy:/etc/squid/certs/squidCA.pem ./squidCA.pem
```

### Trust the certificate

**Windows:**
1. Run `certmgr.msc`
2. Right-click Trusted Root Certification Authorities → Certificates
3. Select All Tasks → Import
4. Browse to `squidCA.pem` and import

**macOS:**
1. Open Keychain Access
2. File → Import Items → Select `squidCA.pem`
3. Double-click the imported certificate
4. Expand Trust section
5. Set "When using this certificate" to "Always Trust"

**Linux (Ubuntu/Debian):**
```bash
sudo cp squidCA.pem /usr/local/share/ca-certificates/squidCA.crt
sudo update-ca-certificates
```

### Enable SSL Bump

To enable HTTPS inspection on port 3129:

1. Edit `squid.conf` and uncomment the SSL bump configuration lines
2. Edit `compose.yaml` and uncomment the port `3129:3129` mapping
3. Edit `Dockerfile` and uncomment `EXPOSE 3129`
4. Rebuild: `docker compose up --build -d`
5. Configure your browser to use port `3129` instead of `3128`
6. Trust the CA certificate (see above)

## Deployment with Komodo

This application is configured to work with Komodo deployment manager. The `komodo.config.toml` file contains the necessary configuration.

### Configuration

The Komodo configuration includes:
- Stack name: `squid_proxy`
- Git repository tracking
- Docker Compose orchestration
- Webhook support for automated deployments

### Deploy

1. Ensure Komodo is installed and configured on your server
2. Add this repository to your Komodo instance
3. Configure the webhook secret in `komodo.config.toml`
4. Deploy using Komodo's interface or CLI

## Project Structure

```
.
├── Dockerfile              # Docker image configuration (Ubuntu/Squid)
├── compose.yaml            # Docker Compose orchestration
├── komodo.config.toml      # Komodo deployment configuration
├── squid.conf              # Squid proxy server configuration
└── README.md               # This file
```

## Configuration

### Squid Configuration

The main configuration is in `squid.conf`. Key settings:

- **Port 3128**: Standard forward proxy (HTTP/HTTPS passthrough)
- **Port 3129**: Optional SSL bump for HTTPS inspection (disabled by default)
- **Cache**: 10GB disk cache, 256MB memory cache
- **Access**: Allows local networks (10.x, 172.16.x, 192.168.x)
- **Privacy**: Removes forwarding headers to protect client information
- **DNS**: Uses Google DNS (8.8.8.8, 8.8.4.4)

### Volumes

The proxy uses Docker volumes for persistence:
- `cache_data`: Stores cached content at `/var/spool/squid`
- `logs`: Stores access and cache logs at `/var/log/squid`

### View Logs

```bash
# Follow access logs
docker compose logs -f proxy

# View logs inside container
docker exec squid_proxy tail -f /var/log/squid/access.log
docker exec squid_proxy tail -f /var/log/squid/cache.log
```

### Check Cache Status

```bash
docker exec squid_proxy squidclient mgr:info
```

## Troubleshooting

### Connection Refused

**Problem**: Browser cannot connect to proxy

**Solutions**:
- Check container is running: `docker compose ps`
- Check logs: `docker compose logs proxy`
- Verify port 3128 is exposed: `docker compose port proxy 3128`
- Ensure no firewall blocking port 3128

### Certificate Errors (with SSL bump)

**Problem**: Browser shows SSL certificate warnings

**Solution**:
- Export and trust the CA certificate (see SSL Certificate Trust section above)
- Ensure you're using port 3129 if SSL bump is enabled
- Verify the certificate was generated: `docker exec squid_proxy ls -l /etc/squid/certs/`

### Slow Performance

**Problem**: Websites load slowly through proxy

**Solutions**:
- Check cache usage: `docker exec squid_proxy squidclient mgr:info`
- Increase cache memory in `squid.conf`: `cache_mem 512 MB`
- Check DNS resolution: `docker exec squid_proxy ping google.com`
- Review logs for errors: `docker compose logs proxy`

### Sites Not Loading

**Problem**: Some websites don't load through proxy

**Solutions**:
- Check blocked ports in `squid.conf` (Safe_ports ACL)
- Review access logs: `docker exec squid_proxy tail -f /var/log/squid/access.log`
- Verify ACL configuration allows your IP range
- Some sites may block proxy traffic

### Cache Not Working

**Problem**: Content is not being cached

**Solutions**:
- Verify cache directory exists: `docker exec squid_proxy ls -l /var/spool/squid`
- Check cache configuration in `squid.conf`
- Some content (HTTPS without SSL bump, dynamic content) cannot be cached
- Review cache log: `docker exec squid_proxy tail -f /var/log/squid/cache.log`

## Security Considerations

- **Default configuration allows local networks only** (10.x, 172.16.x, 192.168.x)
- No authentication required (suitable for trusted local network/single user)
- SSL bump is disabled by default (privacy-respecting)
- For additional security, consider adding HTTP Basic Authentication
- Review and adjust ACLs in `squid.conf` based on your needs

## Advanced Configuration

### Add HTTP Basic Authentication

1. Create password file:
```bash
docker exec -it squid_proxy htpasswd -c /etc/squid/passwords username
```

2. Edit `squid.conf` and uncomment the authentication lines
3. Restart: `docker compose restart proxy`

### Customize Access Control

Edit `squid.conf` to modify ACLs:
- Add allowed IP ranges to `localnet` ACL
- Add blocked domains with `acl blocked_sites dstdomain`
- Configure time-based access with `acl business_hours time`

### Increase Cache Size

Edit `squid.conf`:
```
cache_dir ufs /var/spool/squid 20000 16 256  # 20GB cache
cache_mem 512 MB                              # 512MB memory
```

Then rebuild: `docker compose up --build -d`

## Testing

After setup, test the proxy:

1. Configure your browser to use the proxy (see Browser Configuration)
2. Visit http://example.com (should work)
3. Visit https://www.google.com (should work)
4. Check access logs: `docker compose logs proxy`
5. Verify caching: Visit a site twice and check logs for `TCP_HIT`

## Performance Tips

- Adjust cache size based on available disk space
- Use DNS caching (already configured with Google DNS)
- Enable compression for text-based content
- Monitor cache hit ratio with `squidclient mgr:info`
- Consider using faster storage for cache volume in production

## License

This project configuration is provided as-is for use with Squid proxy server.
