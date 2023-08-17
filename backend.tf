terraform {
  backend "s3" {
    bucket = "teclify-sandbox-143805577160-terraform-state"
    key    = "bdkmsk/terraform.tfstate"
    region = "eu-central-1"
  }
}