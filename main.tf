provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      "for" = "assignment"
    }
  }
}

module "vpc" {
  source = "./vpc"
}

module "a_s3" {
  source = "./s3"
}

module "ec2" {
  source    = "./ec2"
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.pvt_sn_id
}

module "rds" {
  source          = "./rds"
  ec2_instance_id = module.ec2.instance_id
  subnet_id       = module.vpc.pvt_sn_id
  vpc_id          = module.vpc.vpc_id
}
