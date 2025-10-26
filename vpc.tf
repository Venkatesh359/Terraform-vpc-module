##############################################
# VPC Creation
##############################################

# Creates a Virtual Private Cloud (VPC) — this is the main networking boundary in AWS.
resource "aws_vpc" "main" {

  cidr_block           = var.cidr_block # CIDR range for the entire VPC (e.g., 10.0.0.0/16), provided through variables.
  instance_tenancy     = "default"      # Defines the tenancy type. "default" = shared hardware, "dedicated" = dedicated hardware.
  enable_dns_hostnames = true           # Enables DNS hostnames for instances launched in this VPC (needed for public DNS names).
  tags = merge(                         # Tags are merged from multiple sources: user-defined tags, local tags, and a dynamic Name tag.
    var.vpc_tags,                       # Custom VPC tags passed via variables
    local.common_tags,                  # Common tags like environment, project name, etc.
    {
      Name = local.common_name_suffix # Example: roboshop-dev
    }
  )
}


##############################################
# Internet Gateway (IGW)
##############################################

# An Internet Gateway allows communication between the VPC and the internet.
resource "aws_internet_gateway" "main" {
  # Attach IGW to the VPC we just created.
  vpc_id = aws_vpc.main.id

  # Add descriptive tags for the Internet Gateway.
  tags = merge(
    var.igw_tags,      # Custom IGW tags
    local.common_tags, # Common tags
    {
      Name = local.common_name_suffix # Example: roboshop-dev
    }
  )
}


##############################################
# Public Subnets
##############################################

# Creates multiple public subnets across Availability Zones.
resource "aws_subnet" "public" {
  # One subnet per CIDR block defined in var.public_subnet_cidrs.
  count = length(var.public_subnet_cidrs)

  # Associate subnet with the main VPC.
  vpc_id = aws_vpc.main.id

  # Use each CIDR block from the list (e.g., ["10.0.1.0/24", "10.0.2.0/24"])
  cidr_block = var.public_subnet_cidrs[count.index]

  # Assign each subnet to a unique AZ (from locals, e.g., ["us-east-1a", "us-east-1b"])
  availability_zone = local.az_names[count.index]

  # Automatically assign a public IP to instances launched here.
  map_public_ip_on_launch = true

  # Merge and apply tags for the subnet.
  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
    {
      # Example: roboshop-dev-public-us-east-1a
      Name = "${local.common_name_suffix}-public-${local.az_names[count.index]}"
    }
  )
}


##############################################
# Private Subnets
##############################################

# Creates private subnets — used for internal servers, not exposed to the internet.
resource "aws_subnet" "private" {
  # One subnet per CIDR in private subnet list.
  count = length(var.private_subnet_cidrs)

  # Attach to same VPC.
  vpc_id = aws_vpc.main.id

  # Assign subnet CIDR block.
  cidr_block = var.private_subnet_cidrs[count.index]

  # Distribute across availability zones for high availability.
  availability_zone = local.az_names[count.index]

  # Tags for private subnet.
  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
    {
      # Example: roboshop-dev-private-us-east-1a
      Name = "${local.common_name_suffix}-private-${local.az_names[count.index]}"
    }
  )
}


##############################################
# Database Subnets
##############################################

# Creates database subnets — typically used for RDS or database-tier resources.
resource "aws_subnet" "database" {
  # One subnet per CIDR in the database subnet list.
  count = length(var.database_subnet_cidrs)

  # Attach to main VPC.
  vpc_id = aws_vpc.main.id

  # Define subnet CIDR range.
  cidr_block = var.database_subnet_cidrs[count.index]

  # Spread across availability zones for redundancy.
  availability_zone = local.az_names[count.index]

  # Tags for database subnet.
  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
    {
      # Example: roboshop-dev-database-us-east-1a
      Name = "${local.common_name_suffix}-database-${local.az_names[count.index]}"
    }
  )
}

##############################################
# PUBLIC, PRIVATE, DATABASE ROUTE TABLES
##############################################

# Create a Public Route Table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # Associate route table with main VPC

  # Add tags for easy identification
  tags = merge(
    var.public_route_table_tags, # Custom user-defined tags
    local.common_tags,           # Common tags applied to all resources
    {
      Name = "${local.common_name_suffix}-public" # Descriptive name
    }
  )
}

# Create a Private Route Table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-private"
    }
  )
}

# Create a Database Route Table for database subnets
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route_table_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-database"
    }
  )
}

##############################################
# PUBLIC ROUTE (Internet access via IGW)
##############################################

# Route all internet-bound traffic (0.0.0.0/0) from public subnets
# through the Internet Gateway
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"                  # Internet route
  gateway_id             = aws_internet_gateway.main.id # Points to IGW
}

##############################################
# ELASTIC IP (for NAT Gateway)
##############################################

# Allocate an Elastic IP to be used by NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc" # Must be "vpc" for VPC-scoped EIP

  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-nat"
    }
  )
}

##############################################
# NAT GATEWAY (for Private/DB subnets internet access)
##############################################

# NAT Gateway allows private instances to reach the internet
# (for updates, patching, etc.) without being publicly exposed
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id          # Use the EIP created above
  subnet_id     = aws_subnet.public[0].id # NAT Gateway should be in a public subnet

  tags = merge(
    var.nat_gateway_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}"
    }
  )

  # Ensure IGW is created first (ordering dependency)
  depends_on = [aws_internet_gateway.main]
}

##############################################
# PRIVATE ROUTE (through NAT)
##############################################

# Private subnets route internet traffic via NAT Gateway
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

##############################################
# DATABASE ROUTE (through NAT)
##############################################

# Database subnets also route internet traffic via NAT Gateway
# (used for patching/updates, not for public access)
resource "aws_route" "database" {
  route_table_id         = aws_route_table.database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

##############################################
# ROUTE TABLE ASSOCIATIONS
##############################################

# Associate each public subnet with the public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs) # Create one association per subnet
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate each private subnet with the private route table
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate each database subnet with the database route table
resource "aws_route_table_association" "database" {
  count          = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
