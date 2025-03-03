# environments/develop/networking/providers.tf
provider "aws" {
  region = "eu-west-1"
  
  default_tags {
    tags = {
      Environment = "develop"
      Project     = "demo-app"
      ManagedBy   = "terraform"
    }
  }
}