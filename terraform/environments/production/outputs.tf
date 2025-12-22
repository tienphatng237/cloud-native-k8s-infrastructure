# =========================
# EKS Core Outputs
# =========================
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  value = module.eks.cluster_ca
}

# =========================
# IAM Outputs (for future IRSA / Karpenter)
# =========================
output "eks_node_role_arn" {
  value = module.iam_eks.node_role_arn
}

# =========================
# Observability
# =========================
output "observability_private_ips" {
  value = [for i in module.observability.instances : i.private_ip]
}

# =========================
# OpenVPN
# =========================
output "openvpn_public_ip" {
  value = module.openvpn.public_ip
}

output "alb_controller_role_arn" {
  value = module.iam_alb.role_arn
}

output "karpenter_role_arn" {
  value = module.iam_karpenter.role_arn
}
