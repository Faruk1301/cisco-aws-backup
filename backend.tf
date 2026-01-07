terraform {
  backend "s3" {
    bucket         = "faruk-terraform-lab-001"
    key            = "cisco-router/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # dynamodb_table ওয়ার্নিং সরাতে এবং এরর কমাতে আপাতত এটি বাদ রাখছি
    # যদি পরে দরকার হয় আমরা 'use_lockfile = true' ব্যবহার করবো
  }
}