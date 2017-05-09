variable "flavor" {
  default = "m1.small"
}

variable "region" {
}

variable "key_pair" {
  default = "rj45"
}

variable "image_name" {
  default = "Ubuntu 14.04"
}

variable instances {
    default = "2"
}
