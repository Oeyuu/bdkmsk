module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 2, k)]
 
  create_database_subnet_group = false
  enable_nat_gateway           = false
  single_nat_gateway           = false

  tags = local.tags
}
