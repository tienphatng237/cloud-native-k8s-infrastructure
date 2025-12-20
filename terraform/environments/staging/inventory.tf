resource "local_file" "kubernetes_inventory" {
  filename = "${path.root}/../../../ansible/inventories/staging/kubernetes.ini"

  content = <<-EOF
[k0s_controller]
controller ansible_host=${module.compute.k0s_controller.private_ip}

[k0s_workers]
%{for idx, inst in module.compute.k0s_workers~}
worker-${idx + 1} ansible_host=${inst.private_ip}
%{endfor~}

[k0s_cluster:children]
k0s_controller
k0s_workers
EOF
}


resource "local_file" "observability_inventory" {
  filename = "${path.root}/../../../ansible/inventories/staging/observability.ini"

  content = <<-EOF
[observability]
%{for idx, inst in module.compute.observability~}
obser-${idx + 1} ansible_host=${inst.private_ip}
%{endfor~}
EOF
}


resource "local_file" "openvpn_inventory" {
  filename = "${path.root}/../../../ansible/inventories/staging/openvpn.ini"

  content = <<-EOF
[openvpn]
vpn ansible_host=${module.compute.openvpn.public_ip}
EOF
}
