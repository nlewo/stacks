variable "flavor_id" {
  default = 22
}

variable "region" {
  default = "fr0"
}

variable "key_pair" {
  default = "rj45"
}

variable "image_name" {
  default = "Ubuntu 14.04"
}

variable "ssh_key_file" {
}

variable instances {
  type = "map"

  default {
    backend = "2"
  }
}
