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
    # vpc_id = module.vpc_module.vpc_id
    # public_subnet_1_id = module.vpc_module.public_subnet_1_id
    # public_subnet_2_id = module.vpc_module.public_subnet_2_id
    vpc_id = "vpc-039e5e54a507544ec"
    public_subnet_1_id = "subnet-094e16ce489053244"
    public_subnet_2_id = "subnet-0f4bac046a399c023"
    # security_group_allow_http_traffic_id = module.sg_module.security_group_allow_http_traffic_id
    security_group_allow_http_traffic_id = "sg-04fb2f23d9e16ea24"
    ecs_id = module.ecs_module.ecs_id
}   

module "ecs_module" {
    source = "./modules/ecs"
    # vpc_id = module.vpc_module.vpc_id
    # public_subnet_1_id = module.vpc_module.public_subnet_1_id
    # public_subnet_2_id = module.vpc_module.public_subnet_2_id
    vpc_id = "vpc-039e5e54a507544ec"
    public_subnet_1_id = "subnet-094e16ce489053244"
    public_subnet_2_id = "subnet-0f4bac046a399c023"
    # security_group_allow_http_traffic_id = module.sg_module.security_group_allow_http_traffic_id
    security_group_allow_http_traffic_id = "sg-04fb2f23d9e16ea24"
    alb_id = module.alb_module.alb_id
    # target_group_id = module.alb_module.target_group_id
    target_group_id = "arn:aws:elasticloadbalancing:us-east-1:385501908346:targetgroup/products-service-target-group/623025c9385fcf39"
}   

# module "vpc_module" {
#         source = "./modules/vpc"
#         region = data.aws_region.current.name
#         #region = var.region
# }   

# module "sg_module" {
#         source = "./modules/sg"
#         vpc_id = module.vpc_module.vpc_id
# }   

# module "iam_module" {
#         source = "./modules/iam"
# }   

# module "cicd_module" {
#         source = "./modules/cicd"
# }   

module "dynamodb_module" {
        source = "./modules/dynamodb"
}   
