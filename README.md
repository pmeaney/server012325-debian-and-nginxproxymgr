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

- add ssh key
  - to generate new ssh key: `ssh-keygen -t ed25519 -C "emailAddressHere"`
  - Add the .pub key to 1pass. (example key name: LINUX_SSH_KEY_2A, with value of your ssh key)
  - **Don't forget!! -->** the .pub key to digitalocean. Settings > Security > Add SSH Key
  - 👉 Review the section above "Dealing with ssh keys" and be sure to add the ssh key to your ssh config file as mentioned.
