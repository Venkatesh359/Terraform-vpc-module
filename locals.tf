# locals block is used to define reusable local values within the Terraform configuration.
# These values can simplify and standardize repeated values across resources which cant be changed.

locals {

  common_tags = {                  # A reusable map of tags that can be applied to multiple AWS resources.Tags help in identifying resources by project, environment, and management tool.
    Project     = var.project_name # Dynamic tag - takes value from input variable 'project_name'
    Environment = var.environment  # Dynamic tag - takes value from input variable 'environment'
    Terraform   = true             # Static tag - indicates that this resource is managed by Terraform
  }
  common_name_suffix = "${var.project_name}-${var.environment}" # roboshop-dev

  # Fetches the list of available AWS Availability Zones from data source 'aws_availability_zones'.
  # Then selects the first two zones using 'slice(list,start,end)' function.
  # Example: If AZs = [us-east-1a, us-east-1b, us-east-1c,us-east-1d,us-east-1e] this will pick ["us-east-1a", "us-east-1b"]
  az_names = slice(data.aws_availability_zones.available.names, 0, 2)
}
