
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "HELIOS"
      Environment = "Development"
      ManagedBy   = "Terraform"
    }
  }
}
