resource "local_file" "kubernetes_inventory" {
  filename = "${path.root}/../../../ansible/inventories/staging/kubernetes.ini"

  content = <<-EOF
[k0s_controller]
controller ansible_host=${module.compute.k0s_controller.private_ip} ansible_user=ubuntu

[k0s_workers]
%{for idx, inst in module.compute.k0s_workers~}
worker-${idx + 1} ansible_host=${inst.private_ip} ansible_user=ubuntu
%{endfor~}

[k0s_cluster:children]
k0s_controller
k0s_workers

[all:vars]
ansible_ssh_private_key_file=../../../key_pair/k0s_key
EOF
}

resource "local_file" "observability_inventory" {
  filename = "${path.root}/../../../ansible/inventories/staging/observability.ini"

  content = <<-EOF
[observability]
%{for idx, inst in module.compute.observability~}
obser-${idx + 1} ansible_host=${inst.private_ip} ansible_user=ubuntu
%{endfor~}

[all:vars]
ansible_ssh_private_key_file=../../../key_pair/k0s_key
EOF
}

resource "local_file" "openvpn_inventory" {
  filename = "${path.root}/../../../ansible/inventories/staging/openvpn.ini"

  content = <<-EOF
[openvpn]
vpn ansible_host=${module.compute.openvpn.public_ip} ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=../../../key_pair/k0s_key
EOF
}
