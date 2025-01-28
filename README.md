# Automating a server setup with Terraform and Nginx Proxy Manager

In this project we'll automate the process of setting up a Linux server (Debian), using Terraform. Then we'll open the server to web traffic with Nginx Proxy Manager ("NPM"), which will run in a Docker container. We'll setup NPM with SSL Certificates and point it at the frontend of an example application (A Nextjs, Strapi CMS & Postgres based Portfolio website).

We'll use 1password as our password manager in our development environment (in my case, a Macbook Pro m2 laptop), to automate the process of feeding environment variables into different processes (for example, server setup with terraform, ssh logging-in, and transferring project directories with rsync)

## Setting up Terraform Env Vars

#### Side note about setup prior to using Terraform

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

- add ssh key
  - to generate new ssh key: `ssh-keygen -t ed25519 -C "emailAddressHere"`
  - Add the .pub key to 1pass. (example key name: LINUX_SSH_KEY_2A, with value of your ssh key)
  - **Don't forget!! -->** the .pub key to digitalocean. Settings > Security > Add SSH Key
  - 👉 Review the section above "Dealing with ssh keys" and be sure to add the ssh key to your ssh config file as mentioned.

# Step 1: Terraform -- Creating a new server

### When creating a new ssh key

On MacOS

- Don't forget to:
  - add the private ssh key to ssh config file: `~/.ssh/config`
  - add the private ssh key to ssh key chain: `ssh-add ~/.ssh/someKeyName`

### Exporting 1password items

We export items stored in 1password into env vars in our dev environment (that is, our laptop), so Terraform, ssh, rsync, and other tools can access them (as local env vars-- run `env` in your CLI to see what I mean) as needed.

```bash
# Copy & paste this as one block, to set env vars on your laptop, which will be set into the terraform script
export DIGITALOCEAN_ACCESS_TOKEN=$(op item get "2025 Jan 012325 Debian project" --fields label=TF_VAR_DIGITAL_OCEAN_TOKEN_012325) &&
export TF_VAR_LINUX_PASSWORD_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_PASSWORD_DEVOPS_012325) &&
export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) &&
export TF_VAR_LINUX_SSH_KEY_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SSH_KEY_012325) &&
export TF_VAR_LINUX_SERVER_NAME_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_NAME_012325)

# Now we're ready to  move into the terraform project directory and create a new server.
cd terraform-server--Debian-Jan2025-PortfolioEtc
terraform init
terraform apply

# Regarding the CLI output-- save the IP address of your new server in 1pass:
# give it the name: LINUX_SERVER_IPADDRESS_012325
```

# Step 2: Nginx Proxy Manager (NPM) -- Serving traffic

#### SideNote:

- The the "DB_POSTGRES_HOST" item in NPM section of the docker-compose.yml file must be the name of the database docker container. In this case, it's "postgres-for-nginx-proxy-mgr-012825".

### Import the nginx-proxy-mgr docker-compose file:

Export the required env vars from 1pass...

- TF_VAR_LINUX_USER_DEVOPS_012325 will be username you set, to log into the server
- LINUX_SERVER_IPADDRESS_012325 will be the server's IP address. It will be output to the terminal by Terraform (you can always go into the terraform project directory and run `terraform show` to see the IP address in the CLI output again), and you can find it on DigitalOcean in your server hosting dashboard.

```bash
# export the required env vars
export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) && \
export LINUX_SERVER_IPADDRESS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_IPADDRESS_012325)

# Log into the remote server (to test out our login, and to install rsync for transferring files)
ssh "${TF_VAR_LINUX_USER_DEVOPS_012325}"@"${LINUX_SERVER_IPADDRESS_012325}"

# (OPTIONAL) Install rsync if it's not already installed on debian server.  I updated the terraform file to install it automatically:
# sudo apt update
# sudo apt install rsync -y

# now that we've checked our username & pw work, let's upload the nginx proxy manager directory (from our laptop, of course, not the server)
# REMEMBER: You'll need to set both env vars, prior to running this command-- such as if you opened a new terminal window.

export TF_VAR_LINUX_USER_DEVOPS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_USER_DEVOPS_012325) && \
export LINUX_SERVER_IPADDRESS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_IPADDRESS_012325)

# NOTE: This will overwrite (due to trailing slash at end of source dir) any existing directory of the same name & location on your server.
rsync -avvz ./nginx-proxy-mgr-jan2025/ "${TF_VAR_LINUX_USER_DEVOPS_012325}"@"${LINUX_SERVER_IPADDRESS_012325}":~/nginx-proxy-mgr-jan2025

# Build & Start Nginx Proxy Manager docker container in background & view its logs
cd nginx-proxy-mgr-jan2025 && \
docker compose -vvv  -f docker-compose.yml up --build --remove-orphans -d && \
docker compose logs -f nginx-proxy-mgr-012825

# You'll see a bunch of terminal output about NPM booting up, including this line:
Creating a new user: admin@example.com with password: changeme

# Now, visit NPM's admin page on the browser:
# output the IP address, assuming you uploaded it to 1password earlier
# ... or simply copy it from 1pass
export LINUX_SERVER_IPADDRESS_012325=$(op item get "2025 Jan 012325 Debian project" --fields label=LINUX_SERVER_IPADDRESS_012325) && echo "${LINUX_SERVER_IPADDRESS_012325}"
# Now visit NPM's admin page on your browser at http://ServerIP:81    (that is, at port 81.)
# Log in with these credentials, provided by NPM when it boots for the first time:
# user: admin@example.com
# password: changeme

```

# Step 3: Setting up SSL Certs & Docker Containers on NPM

Now that NPM is running, and we've logged into it on our browser, at http://ServerIP:81 ,
we can set it up to serve traffic to our applications' docker containers.

To do this, we'll need to do a little bit of setup with our Domain name's DNS Registrar, and our Hosting provider. I recommend Namecheap & DigitalOcean, respectively.

- Create a domain name
- Point it at the nameservers of your hosting provider
- In hosting provider's dashboard, create DNS A-Records pointing to your server IP, and any subdomains you may want to direct traffic through. For example, you maybe want to have your Strapi CMS running at cms.domainname.com, strapi.domainname.com, or blog.domainname.com . Typically you have at least two A-records: www.domainname.com & domainname.com, pointing at your server's IP address.

### Networking & Docker containers

We'll use this project for our initial project:
https://github.com/pmeaney/portfolio2025-next-strapi-postgres

# Resources & References
