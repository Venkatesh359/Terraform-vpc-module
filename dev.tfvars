# -------------------------
# Core VPC
# -------------------------
cidr_block   = "10.0.0.0/16"
project_name = "roboshop"
environment  = "dev"

# -------------------------
# Common Tags
# -------------------------
vpc_tags = {
  Owner = "devops"
}

igw_tags = {
  Name = "roboshop-dev-igw"
}

# -------------------------
# Subnets
# -------------------------
public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

database_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]

# -------------------------
# Subnet Tags
# -------------------------
public_subnet_tags = {
  Tier = "public"
}

private_subnet_tags = {
  Tier = "private"
}

database_subnet_tags = {
  Tier = "database"
}

# -------------------------
# Route Tables
# -------------------------
public_route_table_tags = {
  Name = "roboshop-dev-public-rt"
}

private_route_table_tags = {
  Name = "roboshop-dev-private-rt"
}

database_route_table_tags = {
  Name = "roboshop-dev-database-rt"
}

# -------------------------
# NAT / EIP
# -------------------------
eip_tags = {
  Name = "roboshop-dev-eip"
}

nat_gateway_tags = {
  Name = "roboshop-dev-nat"
}

# -------------------------
# Peering
# -------------------------
is_peering_required = true



#terraform init
# terraform plan -var-file=dev.tfvars
# terraform apply -var-file=dev.tfvars
