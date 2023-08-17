module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  ingress_rules = [
    "kafka-broker-tcp",
    "kafka-broker-tls-tcp"
  ]

  tags = local.tags
}
