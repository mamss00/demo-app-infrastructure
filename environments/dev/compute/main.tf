# environments/develop/compute/main.tf

# Récupération des informations du réseau
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "demo-app-terraform-state-${data.aws_caller_identity.current.account_id}"
    key    = "dev/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Nécessaire pour obtenir l'ID du compte AWS
data "aws_caller_identity" "current" {}

# Module ECR pour stocker les images Docker
module "ecr" {
  source = "../../../modules/ecr"

  project_name = "demo-app"
  environment  = "dev"
}

# Module ECS pour déployer l'application
module "ecs" {
  source = "../../../modules/ecs"

  project_name        = "demo-app"
  environment         = "dev"
  
  # Connexion au réseau
  vpc_id              = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnet_ids  = data.terraform_remote_state.networking.outputs.private_subnet_ids
  public_subnet_ids   = data.terraform_remote_state.networking.outputs.public_subnet_ids
  
  # Sécurité
  ecs_security_group_id = data.terraform_remote_state.networking.outputs.security_groups.ecs_tasks
  alb_security_group_id = data.terraform_remote_state.networking.outputs.security_groups.alb
  
  # Image de conteneur - à remplacer par votre propre image
  container_image    = "${module.ecr.repository_url}:latest"
  
  # Ressources
  container_cpu      = 256
  container_memory   = 512
  desired_count      = 1
  
  # Configuration des instances EC2
  min_instances      = 1
  max_instances      = 1
  desired_instances  = 1
}

# Outputs
output "ecr_repository_url" {
  value = module.ecr.repository_url
  description = "URL du repository ECR pour pousser des images"
}

output "alb_dns_name" {
  value = module.ecs.alb_dns_name
  description = "DNS name du load balancer"
}