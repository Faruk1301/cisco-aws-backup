terraform {
  backend "s3" {
    bucket         = "faruk-terraform-lab-001"
    key            = "cisco-router/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}