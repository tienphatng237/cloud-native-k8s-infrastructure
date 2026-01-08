variable "vpc_cidr" {}
variable "azs" {}
variable "private_subnets" {}
variable "public_subnet" {}

variable "openvpn_eni_id" {
  description = "Primary network interface ID of OpenVPN EC2"
  type        = string
  default     = null
}

variable "cluster_name" {
  type = string
}
