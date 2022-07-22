variable "app_name" {}
variable "VPC_CIDR" {}
variable "PATH_TO_PRIVATE_KEY" {
  default = "myappkey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "myappkey.pub"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}