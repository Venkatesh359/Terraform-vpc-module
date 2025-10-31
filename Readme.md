# Overview 

```bash 

  #🏗️ 1. VPC (Virtual Private Cloud)  

  -   A VPC is your isolated network environment in AWS. You define its CIDR range (for example, 10.0.0.0/16).

  Example:

  CIDR: 10.0.0.0/16

  This provides IPs from 10.0.0.0 to 10.0.255.255, which you then divide into subnets.


  #🌐2. Subnets

  -Subnets divide your VPC CIDR block into smaller sections — public and private.

  Subnet Type	Example CIDR	Purpose	Route Table Entry

  Public Subnet	10.0.1.0/24	Hosts resources needing internet access (EC2 bastion, ALB, etc.)	Route to Internet Gateway (IGW)

  Private Subnet	10.0.2.0/24	Hosts backend resources (EC2, DBs)	Route to NAT Gateway

   ***3.Public Subnet (10.0.1.0/24)***

   A network directly connected to the Internet via an Internet Gateway (IGW).

   Hosts:

   Bastion Host → Used for SSH access to private servers.

   NAT Gateway → Allows private resources to reach the internet outbound only (for patching, updates, etc.).

   Traffic Flow:

    Internet ↔ IGW ↔ Bastion Host (inbound SSH, web traffic, etc.)

    Private subnet → NAT GW → IGW → Internet (for outbound only)

Public Subnet Route Table Example:

Destination    Target

10.0.0.0/16    local

0.0.0.0/0      igw-123abc


- Private Subnet (10.0.2.0/24):

   No direct Internet access.

   Used for application servers, internal services, or databases.

   Internet traffic routes via NAT Gateway in the public subnet.

Traffic Flow:

  App Server → NAT GW → IGW → Internet (for outbound)

  Bastion Host → App Server (for SSH or app access)

  App Server ↔ DB (internal communication)

Private Subnet Route Table Example:

Destination    Target

10.0.0.0/16    local

0.0.0.0/0      nat-456def


 ***🌉 3. Internet Gateway (IGW)

IGW allows public internet traffic to flow in/out of the VPC.

It must be attached to your VPC.

Only subnets with routes pointing to IGW are public.

Entry/exit point to/from the public internet.

Required for public IP communication.


 ***🔁4. NAT Gateway***

 NAT Gateway lets private subnet instances access the internet\[outbound connections] for updates, package downloads, etc.

 It is deployed in a public subnet.

 Private subnets route internet-bound traffic to this NAT.

 It hides private IPs behind a public Elastic IP (EIP).

🔒 5. Security Groups (SG)

Security Groups act as stateful firewalls at the instance level.

✅ Typical Security Group Rules

| SG Type              | Direction | Protocol | Port Range | Source/Destination     | Purpose                |

| -------------------- | --------- | -------- | ---------- | ---------------------- | ---------------------- |

| Public EC2 (Web/App) | Inbound   | TCP      | 22         | Your IP (`x.x.x.x/32`) | SSH access             |

|                      | Inbound   | TCP      | 80, 443    | `0.0.0.0/0`            | Web access             |

|                      | Outbound  | All      | All        | `0.0.0.0/0`            | Allow all outbound     |

| Private EC2          | Inbound   | TCP      | 22         | Public SG              | SSH from bastion       |

|                      | Inbound   | TCP      | 3306       | App SG                 | Database access        |

|                      | Outbound  | All      | All        | `0.0.0.0/0`            | Allow outbound via NAT |

💡 Stateful behavior: If inbound traffic is allowed, response traffic is automatically allowed.


| SG Name                | Inbound                   | Outbound | Purpose                                  |

| ---------------------- | ------------------------- | -------- | ---------------------------------------- |

| \*\*Bastion-SG\*\*         | TCP 22 (SSH) from your IP | All      | Secure SSH entry point                   |

| \*\*App-SG\*\*             | TCP 22 from Bastion-SG    | All      | App instances accessed only from Bastion |

| \*\*DB-SG\*\* \*(optional)\* | TCP 3306 from App-SG      | All      | DB only accessible from App tier         |


🔁 Traffic Direction (Color Coded)

Red Arrows → Inbound communication (e.g., Bastion → App)

Blue Arrows → Outbound communication (e.g., App → Internet via NAT)

📦 6. Network Flow Summary

| Direction        | Component                               | Description                           |

| ---------------- | --------------------------------------- | ------------------------------------- |

| Inbound Public   | IGW → Public Subnet → EC2 (via SG rule) | Allows internet traffic (e.g. HTTP)   |

| Outbound Public  | EC2 → IGW                               | Internet access from public instances |

| Outbound Private | EC2 → NAT GW → IGW                      | Private instance outbound internet    |

| Inbound Private  | From Bastion / App Layer only           | Controlled via SG rules               |







🧩 Example Architecture

VPC: 10.0.0.0/16

│

├── Public Subnet (10.0.1.0/24)

│    ├── IGW attached

│    ├── NAT Gateway deployed here

│    └── Bastion Host / ALB

│

└── Private Subnet (10.0.2.0/24)

    ├── Route via NAT for outbound

    └── App servers / Databases

```





