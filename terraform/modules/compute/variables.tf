variable "ami" {}

variable "instance_type" {}

variable "key_name" {}

variable "public_key" {
  type        = string
  description = "SSH public key content"
}


variable "private_subnet_ids" {}

variable "public_subnet_id" {}

variable "k0s_sg_id" {}

variable "openvpn_sg_id" {}
