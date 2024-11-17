terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "ai-platform/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
} 