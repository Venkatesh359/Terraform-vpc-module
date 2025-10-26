variable "cidr_block" {
  type        = string
  description = "Please Provide cidr"
}

variable "project_name" {
  type = string #mandatory

}

variable "environment" {
  type = string #mandatory

}


variable "vpc_tags" {
  type    = map(any)
  default = {} #optional

}

variable "igw_tags" {
  type    = map(any)
  default = {}

}

variable "public_subnet_cidrs" {
  type = list(any)

}

variable "public_subnet_tags" {
  type    = map(any)
  default = {}
}


variable "private_subnet_cidrs" {
  type = list(any)

}

variable "private_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "database_subnet_cidrs" {
  type = list(any)

}

variable "database_subnet_tags" {
  type    = map(any)
  default = {}
}

variable "public_route_table_tags" {
  type    = map(any)
  default = {}
}

variable "private_route_table_tags" {
  type    = map(any)
  default = {}
}

variable "database_route_table_tags" {
  type    = map(any)
  default = {}
}

variable "eip_tags" {
  type    = map(any)
  default = {}
}

variable "nat_gateway_tags" {
  type    = map(any)
  default = {}
}

variable "is_peering_required" {
  type    = bool
  default = true
}
