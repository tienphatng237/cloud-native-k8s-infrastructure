output "k0s_sg_id" {
  value = aws_security_group.k0s.id
}

output "openvpn_sg_id" {
  value = aws_security_group.openvpn.id
}
