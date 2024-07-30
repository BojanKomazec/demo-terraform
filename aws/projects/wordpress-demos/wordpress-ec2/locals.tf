
# The Availability Zones data source allows access to the list of AWS AZs which
# can be accessed by an AWS account within the region configured in the provider.
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  app_name               = "wordpress"
  env                    = "dev"
	vpc_cidr = "10.0.0.0/16"
	subnet_cidr = cidrsubnet(local.vpc_cidr, 8, 0)
  availability_zone_name = data.aws_availability_zones.available.names[0]
}