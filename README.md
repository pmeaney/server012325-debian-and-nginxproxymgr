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
      - [Note on Server Sizing (Pertains to Strapi CMS v5, which is a little bit of a hog!)](#note-on-server-sizing-pertains-to-strapi-cms-v5-which-is-a-little-bit-of-a-hog)
  - [Nginx Proxy Manager Configuration](#nginx-proxy-manager-configuration)
    - [Setting Up NPM](#setting-up-npm)
    - [Deploying NPM Configuration](#deploying-npm-configuration)
  - [Docker Cross-Service Networking](#docker-cross-service-networking)
    - [Primary Network Configuration](#primary-network-configuration)
    - [Connecting Additional Services](#connecting-additional-services)
  - [SSL Certificate Setup](#ssl-certificate-setup)
  - [Deployment](#deployment)
  - [❗❗❗ See `nginx-proxy-mgr-jan2025/README.md` for more info on Nginx Proxy Manager setup](#-see-nginx-proxy-mgr-jan2025readmemd-for-more-info-on-nginx-proxy-manager-setup)
    - [Updating NPM Configuration](#updating-npm-configuration)
    - [Verifying Network Configuration](#verifying-network-configuration)
- [Resources \& References](#resources--references)
  - [Source of initial Terraform project code](#source-of-initial-terraform-project-code)
- [Deployment](#deployment-1)

## Overview

This guide walks through automating the setup of a Debian server using Terraform, configuring web traffic routing with Nginx Proxy Manager in Docker, and implementing secure networking between Docker services. We'll use 1Password for managing environment variables across different processes.

## Initial Server Setup with Terraform

### SSH Key Configuration

Before beginning the Terraform setup, ensure your SSH keys are properly configured. If you're new to that, you may want to do some research via Github or DigitalOcean blogs on the topic of ssh key generation & related setup.

```bash
# generate a new key if you need to
# Since we'll use this for our CICD process, DO NOT INCLUDE A PASSCODE when generating the ssh key
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

#### Note on Server Sizing (Pertains to Strapi CMS v5, which is a little bit of a hog!)

Note: make sure the server is big enough!

For my Portfolio project, running three containers (NextJS, StrapiJS, Postgres), plus two more for Infrastruture (Nginx Proxy Manager, Postgres)... My initial server was too small (1 vCPU, 1GB / 25GB Disk, ($6/mo via DigitalOcean)) from what I could see from the charts of cpu usage.

With DigitalOcean, fortunately, there's a feature to re-size the server. Otherwise we would need to re-create a brand new one with terraform, upload our Nginx Proxy Manager docker-compose.yml file to it, built it, etc. However, I did update the server size in the Terraform file config, so in future versions hopefully we'll start with the right size.

_update_: I launched a `micro = "s-2vcpu-2gb"` size, but even then, ran into the same memory issue.

Then, I checked the Strapi v5 Docs [General Guidelines](https://docs.strapi.io/dev-docs/deployment#general-guidelines), and found:

> Hardware specifications for your server (CPU, RAM, storage):
> | Resource | Recommended | Minimum |
> | -------- | ----------- | ------- |
> | CPU | 2+ cores | 1 core |
> | Memory | 4GB+ | 2GB |
> | Disk | 32GB+ | 8GB |

So, Looks like we'll have to go with the `small = "s-2vcpu-4gb"` server size.

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

# Simple way to watch it boot & make sure it runs:
cd nginx-proxy-mgr-jan2025 && \
docker compose up

# This command is to Run in background, then check out logs.  It's a nice way to view the running container, while leaving it running after you exit the logs view.:
cd nginx-proxy-mgr-jan2025 && \
docker compose -vvv -f docker-compose.yml up --build --remove-orphans -d && \
docker compose logs -f nginx-proxy-mgr-012825

# Verify Nginx Proxy Manager is reachable by navigating to this address on your browser:
# NOTE: Be sure it's HTTP and not HTTPS! We haven't yet setup any SSL certs, so HTTPS won't reach anything
http://yourServerIP:81
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

## ❗❗❗ See `nginx-proxy-mgr-jan2025/README.md` for more info on Nginx Proxy Manager setup

### Updating NPM Configuration

To transfer updates you make to your NPM Docker Compose file in a quick, automated way, run this rsync command from your developer environment (laptop), and assuming rsync is installed on the remote server, it'll transfer the whole `nginx-proxy-mgr-jan2025` directory to the server. Useful when initially setting things up & testing things out.

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

# Resources & References

### Source of initial Terraform project code

- oleksii*y. (2022, June 5). \_How to create DigitalOcean droplet using Terraform. A-Z guide*. AWSTip.com. Retrieved from [https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021](https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021)
  - Archived Article: https://archive.is/I2Mh0
  - Original's Raw Source Code as an archived Github Gist: https://gist.githubusercontent.com/alexsplash/5f8f34f4020092b634dfd29316683718/raw/f6a4331346efe3bc333fb3cf1e91203faa1e7bf1/digitalocean.tf
-

# Deployment

Deploy the newest Nginx Proxy Manager config update via rsync instead of git project cloning:

```bash
rsync -avvz ./nginx-proxy-mgr-jan2025/ "${TF_VAR_LINUX_USER_DEVOPS_012325}"@"${LINUX_SERVER_IPADDRESS_012325}":~/nginx-proxy-mgr-jan2025

# if rsync isn't installed on remote server (and your laptop), be sure to install it first.  For debian, for example:
sudo apt install rsync -y

```

```bash
# for ssh login, I like to pull login & ip from 1pass:export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) && \
export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) && \
export LINUX_SERVER_IPADDRESS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_IPADDRESS_012325)=LINUX_SERVER_IPADDRESS_012325)

# then ssh in:
ssh "${TF_VAR_LINUX_USER_DEVOPS_012325}"@"${LINUX_SERVER_IPADDRESS_012325}"

# and maybe view the cloud-init logs to see how everything booted & make sure cloud init installed what it's supposed to (see bottom of ./terraform-server--Debian-Jan2025-PortfolioEtc/yamlScripts/with-envVars.yaml file)
sudo cat /var/log/cloud-init-output.log

```
