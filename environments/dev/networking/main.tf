# environments/develop/networking/main.tf

module "vpc" {
  source = "../../../modules/networking"

  project_name        = "demo-app"
  environment         = "dev"
  vpc_cidr            = "10.0.0.0/16"
  availability_zones  = ["eu-west-1a", "eu-west-1b"]
  private_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets      = ["10.0.101.0/24", "10.0.102.0/24"]
  
  # Optimisations pour réduire les coûts
  single_nat_gateway  = true  # Une seule instance NAT
  enable_vpn_gateway  = false
  enable_flow_logs    = false # Désactivez pour réduire les coûts
}