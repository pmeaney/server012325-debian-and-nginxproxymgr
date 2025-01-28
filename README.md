# Server Setup & Docker Networking Guide

A comprehensive guide for setting up a Linux server with Terraform, configuring Nginx Proxy Manager (NPM), and implementing secure Docker networking across multiple services.

## Table of Contents

- [Server Setup \& Docker Networking Guide](#server-setup--docker-networking-guide)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Initial Server Setup with Terraform](#initial-server-setup-with-terraform)
    - [SSH Key Configuration](#ssh-key-configuration)
    - [Setting Up Environment Variables](#setting-up-environment-variables)
    - [Creating the Server](#creating-the-server)
  - [Nginx Proxy Manager Configuration](#nginx-proxy-manager-configuration)
    - [Setting Up NPM](#setting-up-npm)
    - [Deploying NPM Configuration](#deploying-npm-configuration)
  - [Docker Cross-Service Networking](#docker-cross-service-networking)
    - [Primary Network Configuration](#primary-network-configuration)
    - [Connecting Additional Services](#connecting-additional-services)
  - [SSL Certificate Setup](#ssl-certificate-setup)
  - [Deployment](#deployment)
    - [Updating NPM Configuration](#updating-npm-configuration)
    - [Verifying Network Configuration](#verifying-network-configuration)

## Overview

This guide walks through automating the setup of a Debian server using Terraform, configuring web traffic routing with Nginx Proxy Manager in Docker, and implementing secure networking between Docker services. We'll use 1Password for managing environment variables across different processes.

## Initial Server Setup with Terraform

### SSH Key Configuration

Before beginning the Terraform setup, ensure your SSH keys are properly configured. If you're new to that, you may want to do some research via Github or DigitalOcean blogs on the topic of ssh key generation & related setup.

```bash
# generate a new key if you need to
ssh-keygen -t ed25519 -C "you@yourEmail.com"

# Configure SSH key in ~/.ssh/config
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/yourKeyFilename

# Add key to macOS keychain
ssh-add --apple-use-keychain ~/.ssh/nameOrPathTosshKey
```

### Setting Up Environment Variables

Export required variables from 1Password:

```bash
# Export Terraform variables
export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "2025 Jan 012325 Debian project" --fields label=TF_VAR_DIGITAL_OCEAN_TOKEN_012325) &&
export TF_VAR_LINUX_PASSWORD_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_PASSWORD_DEVOPS_012325) &&
export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) &&
export TF_VAR_LINUX_SSH_KEY_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SSH_KEY_012325) &&
export TF_VAR_LINUX_SERVER_NAME_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_NAME_012325)
```

### Creating the Server

```bash
cd terraform-server--Debian-Jan2025-PortfolioEtc
terraform init
terraform apply
```

## Nginx Proxy Manager Configuration

### Setting Up NPM

First, export required environment variables:

```bash
export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) && \
export LINUX_SERVER_IPADDRESS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_IPADDRESS_012325)
```

### Deploying NPM Configuration

Transfer configuration files to the server:

```bash
rsync -avvz ./nginx-proxy-mgr-jan2025/ "${TF_VAR_LINUX_USER_DEVOPS_012325}"@"${LINUX_SERVER_IPADDRESS_012325}":~/nginx-proxy-mgr-jan2025

# Start NPM containers

# Simple way:
cd nginx-proxy-mgr-jan2025 && \
docker compose up

# More verbose:
cd nginx-proxy-mgr-jan2025 && \
docker compose -vvv -f docker-compose.yml up --build --remove-orphans -d && \
docker compose logs -f nginx-proxy-mgr-012825
```

## Docker Cross-Service Networking

### Primary Network Configuration

In your NPM Docker Compose file, define the shared network:

```yaml
networks:
  main-network--nginxproxymgr:
    name: main-network--nginxproxymgr
```

### Connecting Additional Services

For other Docker Compose files in different directories, connect to the shared network:

```yaml
services:
  your-application:
    image: your-image:tag
    networks:
      - main-network--nginxproxymgr

networks:
  main-network--nginxproxymgr:
    external: true
    name: main-network--nginxproxymgr
```

## SSL Certificate Setup

To configure SSL certificates and serve traffic to your applications:

1. Register a domain name
2. Configure DNS with your registrar
3. Create DNS A-Records pointing to your server IP
4. Access NPM admin panel at `http://<server-ip>:81`
   - Default credentials:
     - Username: admin@example.com
     - Password: changeme

## Deployment

### Updating NPM Configuration

To deploy updates to your NPM configuration in a quick, automated way:

```bash
rsync -avvz ./nginx-proxy-mgr-jan2025/ "${TF_VAR_LINUX_USER_DEVOPS_012325}"@"${LINUX_SERVER_IPADDRESS_012325}":~/nginx-proxy-mgr-jan2025
```

### Verifying Network Configuration

Check network connections using Docker commands:

```bash
# List all networks
docker network ls

# Inspect network connections
docker network inspect main-network--nginxproxymgr

# View connected containers
docker network inspect main-network--nginxproxymgr -f '{{range .Containers}}{{.Name}} {{end}}'
```

This comprehensive guide provides the foundation for setting up a secure, well-organized server infrastructure using modern DevOps practices and tools.
