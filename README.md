# original source of this code:

https://awstip.com/how-to-create-digitalocean-droplet-using-terraform-a-z-guide-df91716f6021

---

### When creating a new ssh key

On MacOS

- Don't forget to:
  - add the private ssh key to ssh config file: `~/.ssh/config`
  - add the private ssh key to ssh key chain: `ssh-add ~/.ssh/someKeyName`

### 1password env vars

```bash
# Copy & paste this as one block, to set env vars on your laptop, which will be set into the terraform script
export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "2025 Jan 012325 Debian project" --fields label=TF_VAR_DIGITAL_OCEAN_TOKEN_012325) &&
export TF_VAR_LINUX_PASSWORD_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_PASSWORD_DEVOPS_012325) &&
export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) &&
export TF_VAR_LINUX_SSH_KEY_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SSH_KEY_012325) &&
export TF_VAR_LINUX_SERVER_NAME_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_NAME_012325)
```

### Terraform

#### Env Vars

**[Keep in Mind]**
👉 Linux/MacOS env vars must be prefixed with TF*VAR* for tf to find them.

- In each section below, find the commands to run to pull env vars out of 1pass

#### Dealing with ssh keys

**[Keep in Mind]**
👉 You may need to add your ssh key to the IdentiyFile section of your `~/.ssh/config` file as shown below. A problem I was running into was that I did not set a password on my ssh key during the ssh-keygen step. Then I would attempt to ssh into a newly tf -created server and I would be prompted for my password. Then I realized I was missing an entry in the ssh config file. Once I added it, things worked as expected.

```bash
# open ~/.ssh/config with your IDE
code  ~/.ssh/config

# Add name of your ssh key to it, like this:
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/yourKeyFilename

# Next, add the new key to your apple OS keychain: (the private, not .pub key)
ssh-add --apple-use-keychain ~/.ssh/nameOrPathTosshKey

```

---

### For Server 3M: Clicks & Codes manually created server, to host 1. Placeholder Website 2. NextJS + Strapi CMS template site

**Server name:**

- label: LINUX_SERVER_NAME_3M
- name: ubuntu-021024-dev-3m
- host: digital ocean

**Description:**

- Created with: Terraform, 1pass
- Purpose:
  - This server was created with terraform & 1pass pw calls for env vars
  - No CICD pipeline. This is a manual project currently
  - I am making it manually just to speed along creation of the CCC website & Strapi setup.

**Github links:**

- none yet

**List of Digital Projects on the server:**

Steps:

- Spin up with Terraform see directory `careful__liveserver_3m`
- Manually create NGINX http, certbot -> certs, NGINX https. The nginx & certbot stuff is located in the local app directory `/Users/patrickmeaney/localhost/0-aa-production/1-ccc-projects-apps/ccc-template-sites-nextjs` at `/Users/patrickmeaney/localhost/0-aa-production/1-ccc-projects-apps/ccc-template-sites-nextjs/ccc-nginx-certbot-021024-manual`
- Next,
  - docker packaging process -- We'll package each nextjs project as a docker package.
    - create it. docker build.
    - docker publish
    - then docker run on remote.

Ideally, all of these will be docker packaged, published, then pulled down onto the server.

- **Project 1:**

  - Name: NextJS Placeholder Website
  - Description: It's basically a placeholder of the website, once the template is done
  - Assets: Simple frontend: 1 nextJS client.

- **Project 2:**

  - Name: NextJS + Strapi CMS template site
  - Description: This is the end goal. NextJS & Strapi client. A template, containing sections for:
    - 1. Before & after template
    - 2. Case study template
  - Assets:
    - 1 strapi CMS
    - 1 nextJS client

- **Project 3:**

  - Name: pmeaney.com
  - Description: portfolio site as a NextJS site

- Local laptop Directory: /Users/patrickmeaney/localhost/0-aa-production/ ??????

### Commands for Server 3M. Load from 1pass to Local Laptop Env to Terraform Env var

```bash
# tf only picks up env vars that are prefixed with TF_VAR_
# The DigitalOcean token is not used within the TF script so it does not need the TF_VAR_ prefix.
export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "ClicksAndCodes 3M server" --fields label=DO_TOKEN_CCC_021024_3M)

# Note that this set of tf env vars has `&&` connecting them, so copy & paste them as a block.
export TF_VAR_LINUX_USER_DEVOPS_3M=$(op item get "ClicksAndCodes 3M server" --fields label=LINUX_USER_DEVOPS_3M) &&
export TF_VAR_LINUX_SSH_KEY_3M=$(op item get "ClicksAndCodes 3M server" --fields label=LINUX_SSH_KEY_3M) &&
export TF_VAR_LINUX_SERVER_NAME_3M=$(op item get "ClicksAndCodes 3M server" --fields label=LINUX_SERVER_NAME_3M)
```

---

### For Server 2A

**Server name:**

- label: LINUX_SERVER_NAME_2A
- name: ubuntu-120823-dev-2a
- host: digital ocean

**List of Digital Projects on the server:**

- Project 1

  - Created with: Terraform, 1pass
  - Purpose:

    - This server was created with terraform (& 1pass pw calls for env vars) to work on automated CICD pipeline.
    - The CICD pipeline is the one which unrolls two docker containers (nginx, certbot) to automate HTTPS setup

  - just the ccc-nginx-certbot project
    - nginx
    - certbot
    - CICD github action workflow

**Github links:**

- https://github.com/clicksandcodes/ccc-nginx-certbot
  Local laptop Directory:
- /Users/patrickmeaney/localhost/0-aa-production/1-ccc-projects-infra/ccc-nginx-certbot

### Commands for Server 2A. Load from 1pass to Local Laptop Env to Terraform Env var

```bash
# tf only picks up env vars that are prefixed with TF_VAR_
# The DigitalOcean token is not used within the TF script so it does not need the TF_VAR_ prefix.
export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "ClicksAndCodes 2A server" --fields label=DO_TOKEN_CCC_120823_2A)

# Note that this set of tf env vars has `&&` connecting them, so copy & paste them as a block.
export TF_VAR_LINUX_USER_DEVOPS_2A=$(op item get "ClicksAndCodes 2A server" --fields label=LINUX_USER_DEVOPS_2A) &&
export TF_VAR_LINUX_SSH_KEY_2A=$(op item get "ClicksAndCodes 2A server" --fields label=LINUX_SSH_KEY_2A) &&
export TF_VAR_LINUX_SERVER_NAME_2A=$(op item get "ClicksAndCodes 2A server" --fields label=LINUX_SERVER_NAME_2A)
```

---

---

---

### Notes with additional detail

For each server, we will use all new env vars, secrets, keys, etc.

- add ssh key
  - to generate new ssh key: `ssh-keygen -t ed25519 -C "emailAddressHere"`
  - Add the .pub key to 1pass. (example key name: LINUX_SSH_KEY_2A, with value of your ssh key)
  - **Don't forget!! -->** the .pub key to digitalocean. Settings > Security > Add SSH Key
  - 👉 Review the section above "Dealing with ssh keys" and be sure to add the ssh key to your ssh config file as mentioned.
  - (Later, if you use CICD you'll need to add the private key to its secrets or in some way get the private key can be upload to the remote server it generates)
- Generate a Digital Ocean API key & add it to 1pass (example key name: DO_TOKEN, with value of your DO API Key)
- Pick server name & add it to 1pass (example key name: LINUX_SERVER_NAME, with value of your chosen server name)
- Pick server user's name & add it to 1pass (example key name: LINUX_USER_DEVOPS, with value of your chosen server user name)
