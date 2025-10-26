
# -------------------------------
# OUTPUTS SECTION
# -------------------------------
# The 'output' blocks in Terraform are used to display values after
# 'terraform apply' or to pass data between modules (like VPC IDs, subnet IDs, etc.)

# ----------------------------------------
# Output 1: VPC ID
# ----------------------------------------
output "vpc_id" {
  # 'value' specifies what should be output.
  # Here, we are fetching the 'id' attribute of the 'aws_vpc.main' resource.
  # This gives the unique identifier of the created VPC.
  value = aws_vpc.main.id
}

# ----------------------------------------
# Output 2: Public Subnet IDs
# ----------------------------------------
output "public_subnet_ids" {
  # 'aws_subnet.public[*].id' uses the splat operator (*) to get a list of all public subnet IDs created using the 'aws_subnet.public' resource.
  # If multiple public subnets are defined, this returns all their IDs in a list.
  value = aws_subnet.public[*].id
}

# ----------------------------------------
# Output 3: Private Subnet IDs
# ----------------------------------------
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

# ----------------------------------------
# Output 4: Database Subnet IDs
# ----------------------------------------
output "database_subnet_ids" {
  # This outputs the IDs of all database subnets.Typically used for RDS or other database services which need isolated subnet
  value = aws_subnet.database[*].id
}
