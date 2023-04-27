terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.52.0"
        }
    }

    backend "s3" {
        bucket = "terraform-state-files-20231101"
        key = "terraform.tfstate"
    }
}

provider "aws" {
    region = "us-east-1"
}

data "aws_region" "current" {}

module "alb_module" {
    source = "./modules/alb"
    vpc_id = module.vpc_module.vpc_id
    public_subnet_1_id = module.vpc_module.public_subnet_1_id
    public_subnet_2_id = module.vpc_module.public_subnet_2_id
    security_group_allow_http_traffic_id = module.sg_module.security_group_allow_http_traffic_id
    ecs_id = module.ecs_module.ecs_id
}   

module "ecs_module" {
    source = "./modules/ecs"
    vpc_id = module.vpc_module.vpc_id
    public_subnet_1_id = module.vpc_module.public_subnet_1_id
    public_subnet_2_id = module.vpc_module.public_subnet_2_id
    security_group_allow_http_traffic_id = module.sg_module.security_group_allow_http_traffic_id
    target_group_id = module.alb_module.target_group_id
}   

module "vpc_module" {
        source = "./modules/vpc"
        region = data.aws_region.current.name
}   

module "sg_module" {
        source = "./modules/sg"
        vpc_id = module.vpc_module.vpc_id
}    

module "dynamodb_module" {
        source = "./modules/dynamodb"
}

module "eks_module" {
        source = "./modules/eks"
}

# module "cicd_module" {
#         source = "./modules/cicd"
# }  