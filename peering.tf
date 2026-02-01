############################################
# VPC PEERING CONNECTION
############################################

# This resource creates a VPC Peering Connection between two VPCs
# - One is the requester (the VPC we are creating)
# - The other is the acceptor (the existing/default VPC)

resource "aws_vpc_peering_connection" "default" { # The resource will only be created if peering is required

  count       = var.is_peering_required ? 1 : 0 # 'count' allows conditional creation based on the variable 'is_peering_required'
  peer_vpc_id = data.aws_vpc.default.id         # The ID of the peer VPC (the acceptor side)
  vpc_id      = aws_vpc.main.id                 # The ID of our main VPC (the requester side)

  accepter {                               # Configuration for the accepter side of the peering connection
    allow_remote_vpc_dns_resolution = true # Enables DNS resolution of private hostnames across VPCs
  }

  requester {                              # Configuration for the requester side of the peering connection
    allow_remote_vpc_dns_resolution = true # Enables DNS resolution of private hostnames across VPCs
  }

  auto_accept = true # Automatically accept the peering connection (works if both VPCs are in the same AWS account)


  # Merge tags for better management and identification
  # Combines:
  # - vpc_tags from variables
  # - common_tags from locals
  # - a custom "Name" tag using the local name suffix

  tags = merge(
    var.vpc_tags,
    local.common_tags,
    {
      Name = "${local.common_name_suffix}-default"
    }
  )
}

############################################
# ROUTE FROM PUBLIC ROUTE TABLE TO DEFAULT VPC
############################################

resource "aws_route" "public_peering" { # This creates a route in our VPC’s public route table ; allowing communication to the default VPC via peering

  count                     = var.is_peering_required ? 1 : 0                    # Only create this route if peering is enabled
  route_table_id            = aws_route_table.public.id                          # The route table in our VPC (public subnet)
  destination_cidr_block    = data.aws_vpc.default.cidr_block                    # The CIDR block of the peer VPC (default VPC)
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Reference to the VPC peering connection created above
}



############################################
# ROUTE FROM PUBLIC ROUTE TABLE TO PRIVATE VPC
############################################

resource "aws_route" "private_peering" {
  count                     = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}


############################################
# ROUTE FROM DEFAULT VPC TO OUR VPC
############################################

resource "aws_route" "default_peering" { # This creates a route in the default VPC’s main route table ; allowing it to communicate back to our custom VPC

  count                     = var.is_peering_required ? 1 : 0                    # Only create this route if peering is enabled
  route_table_id            = data.aws_route_table.main.id                       # The main route table of the default VPC (fetched using a data source)
  destination_cidr_block    = var.cidr_block                                     # Destination CIDR of our custom VPC
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # Reference to the same VPC peering connection
}
