locals {
  acc_id       = "143805577160"
  company_name = "teclify"
  prefix       = "${local.company_name}-sandbox-${local.acc_id}"
  app          = "msk"
  full_prefix  = "${local.prefix}-${local.app}"

}


locals {
  name   = "mskcluster"
  region = "eu-central-1"

  vpc_cidr = "10.204.96.0/24"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  secrets = ["producer", "consumer"]

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-msk-kafka-cluster"
    GithubOrg  = "terraform-aws-modules"
  }
}