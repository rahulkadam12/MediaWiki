variable "app_name" {}
variable "VPC_CIDR" {}
variable "PATH_TO_PRIVATE_KEY" {
  default = "wikimedia"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "wikimedia.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}