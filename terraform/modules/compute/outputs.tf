output "k0s_controller" {
  value = aws_instance.k0s_controller
}

output "k0s_workers" {
  value = aws_instance.k0s_workers
}

output "observability" {
  value = aws_instance.observability
}

output "openvpn" {
  value = aws_instance.openvpn
}
