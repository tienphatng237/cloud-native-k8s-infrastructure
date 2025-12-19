# =========================
# OUTPUTS
# =========================

output "openvpn_public_ip" {
  description = "Public IP of OpenVPN server"
  value       = module.compute.openvpn.public_ip
}

output "k0s_controller_private_ip" {
  description = "Private IP of k0s controller node"
  value       = module.compute.k0s_controller.private_ip
}

output "k0s_workers_private_ips" {
  description = "Private IPs of k0s worker nodes"
  value       = module.compute.k0s_workers[*].private_ip
}

output "observability_private_ips" {
  description = "Private IPs of observability nodes"
  value       = module.compute.observability[*].private_ip
}
