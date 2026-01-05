# stack_test

A simple Docker Compose web application ready for Komodo deployment.

## Overview

This is a basic web application using Nginx to serve static content. It's containerized using Docker and orchestrated with Docker Compose, making it ready for deployment with Komodo.

## Prerequisites

- Docker
- Docker Compose
- (Optional) Komodo for deployment management

## Local Development

### Build and run the application

```bash
docker-compose up --build
```

The web application will be available at `http://localhost:8080`

### Stop the application

```bash
docker-compose down
```

## Deployment with Komodo

This application is configured to work with Komodo deployment manager. The `komodo.config.toml` file contains the necessary configuration.

### Configuration

The Komodo configuration includes:
- Stack name: `stack_test`
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
├── Dockerfile              # Docker image configuration
├── docker-compose.yml      # Docker Compose orchestration
├── komodo.config.toml      # Komodo deployment configuration
├── nginx.conf              # Nginx web server configuration
└── html/
    └── index.html          # Static web content
```

## Customization

- Modify `html/index.html` to change the web content
- Update `nginx.conf` for custom Nginx configuration
- Adjust `docker-compose.yml` for additional services or configuration
- Configure `komodo.config.toml` for your deployment environment