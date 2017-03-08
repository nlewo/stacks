variable "flavor_id" {
  default = 22
}

variable "region" {
  default = "fr1"
}

variable "key_pair_name" {
}

variable "image_name" {
  default = "Ubuntu 14.04"
}

variable "name" {
  default = "contrail-devstack"
}

variable "contrail_branch" {
  default = "R2.21-cloudwatt"
}
