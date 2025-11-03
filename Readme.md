# Terraform AWS VPC

This module creates the following resources.
# 🏗️ VPC Infrastructure Terraform Module

## Overview
This Terraform module provisions a complete Virtual Private Cloud (VPC) network setup with public, private, and database subnets across two Availability Zones in **us-east-1**. It also configures internet access, NAT gateway routing, and VPC-to-default VPC peering.

---

## 🚀 Resources Created

### **VPC**
- Creates an isolated **Virtual Private Cloud (VPC)** as the main networking boundary.
- DNS hostnames are enabled for instances to get public DNS names.
- Tagged dynamically with environment, project name, and common tags.

---

### **Internet Gateway (IGW)**
- Attaches to the VPC to allow inbound/outbound traffic between the VPC and the Internet.
- Required for public subnets to have internet access.

---

### **Subnets**
| Type | Purpose | Availability Zones | Description |
|------|----------|--------------------|--------------|
| Public | Internet-facing layer | `us-east-1a`, `us-east-1b` | Hosts public resources like load balancers or bastion hosts. |
| Private | Application layer | `us-east-1a`, `us-east-1b` | Hosts internal EC2 instances not accessible from the Internet. |
| Database | Data layer | `us-east-1a`, `us-east-1b` | Hosts databases (e.g., RDS) that are isolated from direct public access. |

Each subnet:
- Uses CIDR blocks passed through variables (`public_subnet_cidrs`, `private_subnet_cidrs`, `database_subnet_cidrs`).
- Is distributed across AZs for **high availability**.
- Is automatically tagged with environment and zone information.

---

### **Route Tables**
| Route Table | Purpose | Default Route |
|--------------|----------|----------------|
| Public | Handles routing for public subnets | `0.0.0.0/0 → IGW` |
| Private | Handles routing for private subnets | `0.0.0.0/0 → NAT Gateway` |
| Database | Handles routing for database subnets | `0.0.0.0/0 → NAT Gateway` (for patching/updates only) |

Each route table is tagged and associated with the corresponding subnets.

---

### **Elastic IP (EIP)**
- Allocates a **static public IP** for the NAT Gateway.
- Ensures consistent outbound IP address for private/database resources.

---

### **NAT Gateway**
- Deployed in the **public subnet (us-east-1a)**.
- Enables instances in **private** and **database** subnets to **access the internet** (e.g., for OS updates) **without being reachable from the internet**.
- Depends on the Internet Gateway creation.

---

### **Routing Setup**
- **Public Route Table**: Directs `0.0.0.0/0` to the **Internet Gateway**.
- **Private Route Table**: Directs `0.0.0.0/0` to the **NAT Gateway**.
- **Database Route Table**: Also routes `0.0.0.0/0` via the **NAT Gateway**.
- **Route Table Associations**: Each subnet is linked to the correct route table automatically.

---

### **VPC Peering (Optional Extension)**
- The module supports adding **VPC peering** between this custom VPC and the **default VPC**.
- Routes are added on both sides to enable private communication between the two VPCs.

---

## 🌐 **Network Flow Summary**

| Subnet Type | Internet Access | Route Through | Publicly Accessible |
|--------------|----------------|----------------|---------------------|
| Public | Yes (Inbound + Outbound) | Internet Gateway | ✅ Yes |
| Private | Outbound Only | NAT Gateway | ❌ No |
| Database | Outbound Only (for patching) | NAT Gateway | ❌ No |

---

## 🧭 **High-Level Architecture**

               +-------------------------+
               |       Internet          |
               +-----------+-------------+
                           |
                       [ IGW ]
                           |
      +-----------------------------------------+
      |                 VPC                    |
      |  CIDR: 10.0.0.0/16                     |
      |                                         |
      |  +-------------+       +-------------+  |
      |  | Public Sub  |       | Public Sub  |  |
      |  | us-east-1a  |       | us-east-1b  |  |
      |  | EC2, LB, etc|       | EC2, LB, etc|  |
      |  +------▲------+       +------+-------+  |
      |         | NAT GW (EIP)        |          |
      |         +---------------------+          |
      |                                         |
      |  +-------------+       +-------------+  |
      |  | Private Sub |       | Private Sub |  |
      |  | us-east-1a  |       | us-east-1b  |  |
      |  | App Servers |       | App Servers |  |
      |  +-------------+       +-------------+  |
      |                                         |
      |  +-------------+       +-------------+  |
      |  | DB Subnet   |       | DB Subnet   |  |
      |  | us-east-1a  |       | us-east-1b  |  |
      |  | RDS, DB     |       | RDS, DB     |  |
      |  +-------------+       +-------------+  |
      |                                         |
      +-----------------------------------------+
                           |
                     [ VPC Peering ]
                           |
                  +--------------------+
                  |   Default VPC      |
                  +--------------------+


### Inputs


---

## ⚙️ **Inputs**

| Variable | Description | Example |
|-----------|--------------|----------|
| `vpc_cidr` | CIDR block for the VPC | `"10.0.0.0/16"` |
| `public_subnet_cidrs` | List of CIDRs for public subnets | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | List of CIDRs for private subnets | `["10.0.3.0/24", "10.0.4.0/24"]` |
| `database_subnet_cidrs` | List of CIDRs for DB subnets | `["10.0.5.0/24", "10.0.6.0/24"]` |
| `az_names` | List of Availability Zones | `["us-east-1a", "us-east-1b"]` |
| `vpc_tags`, `igw_tags`, `subnet_tags`, etc. | Custom tags for each resource type | `{ Environment = "dev" }` |

---

## 🧩 **Outputs**

| Output | Description |
|---------|--------------|
| `vpc_id` | The ID of the created VPC |
| `public_subnet_ids` | List of public subnet IDs |
| `private_subnet_ids` | List of private subnet IDs |
| `database_subnet_ids` | List of database subnet IDs |
| `nat_gateway_id` | ID of the created NAT Gateway |
| `internet_gateway_id` | ID of the Internet Gateway |

---

