# tf with env vars fed from OS CLI

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}



locals {
  // Map of pre-named sizes to look up from
  sizes = {
    nano      = "s-1vcpu-1gb"
    micro     = "s-2vcpu-2gb"
    small     = "s-2vcpu-4gb"
    medium    = "s-4vcpu-8gb"
    large     = "s-6vcpu-16gb"
    x-large   = "s-8vcpu-32gb"
    xx-large  = "s-16vcpu-64gb"
    xxx-large = "s-24vcpu-128gb"
    maximum   = "s-32vcpu-192gb"
  }
  // Map of regions
  regions = {
    new_york_1    = "nyc1"
    new_york_3    = "nyc3"
    san_francisco = "sfo3"
    amsterdam     = "ams3"
    singapore     = "sgp1"
    london        = "lon1"
    frankfurt     = "fra1"
    toronto       = "tor1"
    india         = "blr1"
  }
}

provider "digitalocean" {}

# the SERVER_NAME is not as important to set via env var... but we will go ahead and do it
variable "LINUX_SERVER_NAME_012325" {
  type = string
  description = "environment variable for devops user"
  default = "blahServerName"
}

variable "LINUX_USER_DEVOPS_012325" {
  type = string
  description = "environment variable for devops user"
  default = "blahLinuxUser"
}

variable "LINUX_PASSWORD_DEVOPS_012325" {
  type = string
  description = "environment variable for devops users password"
  default = "blahLinuxUserPassword"
}

variable "LINUX_SSH_KEY_012325" {
  type = string
  description = "environment variable for devops ssh key"
  default = "blahSshKey"
}

data "template_file" "my_example_user_data" {
  template = templatefile("./yamlScripts/with-envVars.yaml",
    {
      LINUX_USER_DEVOPS_012325 = "${var.LINUX_USER_DEVOPS_012325}",
      LINUX_PASSWORD_DEVOPS_012325 = "${var.LINUX_PASSWORD_DEVOPS_012325}",
      LINUX_SSH_KEY_012325 = "${var.LINUX_SSH_KEY_012325}",
    })
}

resource "digitalocean_droplet" "droplet" {
  image     = "debian-12-x64"
  name      = "${var.LINUX_SERVER_NAME_012325}"
  region    = local.regions.san_francisco
  size      = local.sizes.small
  tags      = ["012325", "2025", "portfolio", "terraform", "docker", "debian"]
  user_data = data.template_file.my_example_user_data.rendered
}

output "ip_address" {
  value       = digitalocean_droplet.droplet.ipv4_address
  description = "The public IP address of your droplet."
}

output "tf_apply_timestamp" {
  value       = timestamp()
  description = "Timestamp of apply"
}

# If you want to make sure the yaml file was properly filled with env vars, you can uncomment this output statement and terraform will show the env vars in situ
# output "template_file_contents" {
#   value = data.template_file.my_example_user_data.rendered
# }

# output "LINUX_SERVER_NAME_012325" {
#   value = "${var.LINUX_SERVER_NAME_012325}"
# }

# output "LINUX_USER_DEVOPS_012325" {
#   value = "${var.LINUX_USER_DEVOPS_012325}"
# }

# output "LINUX_SSH_KEY_012325" {
#   value = "${var.LINUX_SSH_KEY_012325}"
# }