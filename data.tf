# ============================================
# Get all available Availability Zones in region
# ============================================
data "aws_availability_zones" "available" {
  # Fetches only those AZs which are currently available for use
  state = "available"
}

# ============================================
# Get details of the default VPC in this AWS account & region
# ============================================
data "aws_vpc" "default" {
  # Setting this to true fetches the default VPC that AWS creates automatically
  default = true
}

# ============================================
# Get details of the main route table of the default VPC
# ============================================
data "aws_route_table" "main" {
  # Uses the default VPC ID from the data source above
  vpc_id = data.aws_vpc.default.id

  # Filter ensures we only get the "main" route table of that VPC
  filter {
    name   = "association.main"
    values = ["true"]
  }
}
