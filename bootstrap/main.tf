provider "aws" {
  region = "eu-central-1"   
}

resource "aws_s3_bucket" "bucket" {
  bucket = "teclify-sandbox2-143805577160-terraform-state"
}
