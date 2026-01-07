terraform {
  backend "s3" {
    bucket  = "faruk-terraform-lab-001"
    key     = "cisco-router/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    # dynamodb_table এবং অন্যান্য ওয়ার্নিং সৃষ্টিকারী লাইনগুলো বাদ দেওয়া হয়েছে
  }
}