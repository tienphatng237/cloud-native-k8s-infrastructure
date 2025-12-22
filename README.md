# Cloud-Native Infrastructure for Kubernetes

This repository contains the **Infrastructure as Code (IaC)** implementation
for deploying a **k0s Kubernetes cluster on AWS**, focusing on a
**staging environment** designed according to cloud-native and DevOps best practices.

The infrastructure provisioning is handled using **Terraform**, while
**Ansible** is used for system configuration and observability deployment.

---

## 1. Overview

The objective of this project is to design and deploy a **cloud-native infrastructure** capable of running a k0s-based Kubernetes cluster in a manner
that closely resembles real-world production environments.

Key design principles include:

- Modular and reusable infrastructure design
- Clear separation between infrastructure provisioning and configuration management
- Secure and Kubernetes-ready network architecture
- Automated generation of Ansible inventories from Terraform outputs
- Observability-first approach for monitoring and logging

## 2. Infrastructure Deployment and Configuration

The infrastructure is deployed using Terraform with a **module-based architecture**.
Each module is responsible for a specific layer of the infrastructure, including
networking, security, and compute resources.

Terraform is also responsible for generating dynamic Ansible inventory files,
which enables seamless integration between infrastructure provisioning and
system configuration.

---

### 2.1 Staging Environment

The **staging environment** serves as a controlled platform for deploying,
testing, and validating a k0s Kubernetes cluster before any future
production-oriented extensions.

![Staging Environment Architecture](images/staging-env.png)

#### Staging Environment Characteristics

- Deployment across multiple Availability Zones to simulate real-world conditions
- A dedicated VPC with isolated private and public subnets
- k0s Kubernetes cluster consisting of:
  - One controller node
  - Multiple worker nodes
- Dedicated observability nodes running outside the Kubernetes cluster
- Secure management access via an OpenVPN server
- Outbound internet access for private instances through a NAT Gateway
- Load balancing capabilities for Kubernetes services using MetalLB and NGINX

Terraform automatically generates Ansible inventory files and places them under:

```
ansible/inventories/staging/
```

This approach ensures infrastructure consistency and eliminates the need for
hardcoded IP addresses during configuration.

#### Infrastructure Configuration

As part of the staging environment setup, secure access to private
infrastructure components is established before deploying Kubernetes
and observability services.

<details>
<summary><strong>Click here to view full infrastructure configuration steps (OpenVPN, k0s, MetalLB)</strong></summary>

<br/>

##### 1️⃣ OpenVPN Deployment (Secure Access to Private Subnets)

To securely manage EC2 instances located in private subnets, an OpenVPN
server is deployed as a controlled administrative access gateway.
This design eliminates the need to expose internal resources to the
public internet and closely aligns with real-world production security
best practices.

The OpenVPN server is provisioned and configured using **Ansible** to
ensure repeatability and consistency across environments.

---

**Connectivity Test**

Before deploying OpenVPN, verify SSH connectivity to the OpenVPN instance:

```bash
ansible -i inventories/staging/openvpn.ini openvpn -m ping
```

If the connectivity test succeeds, deploy the OpenVPN server using:

```bash
ansible-playbook -i inventories/staging/openvpn.ini playbooks/openvpn_setup.yml
```

After the playbook completes, the OpenVPN client configuration file
(`devops.ovpn`) is automatically generated on the server and fetched to
the local management machine.

---

**OpenVPN Client Configuration**

###### 🪟 Windows Clients

Copy the generated OpenVPN client configuration file to the OpenVPN
configuration directory on Windows:

```bash
cp vpn/devops.ovpn /mnt/c/Users/<username>/OpenVPN/config/
```

**Example:**

```bash
cp vpn/devops.ovpn /mnt/c/Users/phat4/OpenVPN/config/
```

After copying the file, open **OpenVPN Connect** and establish the VPN
connection using the imported configuration.

---

###### 🐧 Linux / WSL Clients (Recommended for DevOps Automation)

For Linux or WSL-based environments (used for Ansible, Terraform, and
kubectl operations), run OpenVPN directly inside the system.

Install OpenVPN if it is not already available:

```bash
sudo apt update
sudo apt install -y openvpn
```

Connect to the VPN using the generated configuration file:

```bash
sudo openvpn --config ~/devops.ovpn
```

Once the VPN connection is established, the system will receive routes
to the private VPC subnets, enabling direct access to internal EC2
instances.

---

**Accessing Private EC2 Instances**

After connecting to the VPN, administrators can securely access EC2
instances in private subnets via SSH:

```bash
ssh -i key_pair/k0s_key ubuntu@10.0.1.167
```

This access method ensures that all administrative traffic flows through the VPN tunnel, maintaining strict network isolation and minimizing the attack surface of the infrastructure.

##### 2️⃣ k0s Kubernetes Cluster Deployment (Controller & Workers)

After secure access to the private subnets has been established via OpenVPN,
the k0s Kubernetes cluster is deployed using Ansible.

The cluster is composed of:
- One k0s controller node responsible for control plane operations
- Multiple k0s worker nodes responsible for running application workloads

The deployment process is fully automated using a dedicated Ansible playbook,
ensuring consistency and repeatability across environments.

**Cluster deployment command:**

```bash
ansible-playbook -i inventories/staging/kubernetes.ini playbooks/k0s_setup.yml
```
This playbook performs the following actions:

- Installs k0s binaries on controller and worker nodes

- Initializes the k0s control plane on the controller node

- Joins worker nodes to the cluster using a secure token-based mechanism

- Configures kubeconfig access for cluster administration

*Cluster verification*

After the deployment completes, connect to the controller node via SSH:
```bash
ssh -i key_pair/k0s_key ubuntu@<controller-private-ip>
```

Verify that all nodes have successfully joined the cluster by executing:

```bash 
k0s kubectl get nodes
```
Example output: 

![k0s get nodes](images/k0s-get-nodes.png)

At this stage, all worker nodes should appear in the cluster and reach the
Ready state once networking components are fully initialized. This confirms
that the k0s cluster has been successfully deployed and is ready for
subsequent configuration steps such as load balancing and observability.

##### 3️⃣ MetalLB Deployment (LoadBalancer Support for k0s)

In a self-managed Kubernetes environment such as k0s running on EC2,
cloud-native LoadBalancer services are not available by default.
To enable service exposure in a production-like manner, MetalLB is deployed
as the load-balancing solution for the staging cluster.

MetalLB is configured in **Layer 2 (L2) mode**, which is suitable for
staging and on-premise–like environments and integrates well with
private subnets in AWS.

The deployment is fully automated using Ansible.

**MetalLB deployment command:**

```bash
ansible-playbook \
  -i inventories/staging/kubernetes.ini \
  playbooks/metallb_setup.yml
```

This playbook performs the following actions:

- Installs MetalLB Custom Resource Definitions (CRDs)
- Deploys MetalLB controller and speaker components
- Configures an IP address pool from the private subnet
- Enables Layer 2 advertisement for IP allocation

*Deployment verification*

After deployment, verify that the MetalLB namespace has been created:

```bash
sudo k0s kubectl get namespaces
```

Expected namespace:

``metallb-system``


Verify that MetalLB components are running:

```bash
sudo k0s kubectl get pods -n metallb-system
```

At this stage, MetalLB is ready to assign private IP addresses to
Kubernetes services of type LoadBalancer. Application-level services
will be deployed and validated in later stages of the project.

---

## Author

This project is developed as part of a **cloud-native infrastructure and DevOps study**,
with an emphasis on Kubernetes deployment, observability, and staging environment design.
