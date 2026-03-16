provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      "for" = "assignment"
    }
  }
}

module "iam" {
  source = "./iam"
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
  bucket_id = module.a_s3.bucket.id
  role_name = module.a_s3.role_name
}

module "rds" {
  source          = "./rds"
  ec2_instance_id = module.ec2.instance_id
  subnet_ids      = [module.vpc.pvt_sn_id, module.vpc.pub_sn_id]
  vpc_id          = module.vpc.vpc_id
}

module "alb" {
  source          = "./alb"
  ec2_instance_id = module.ec2.instance_id
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = [module.vpc.pvt_sn_id, module.vpc.pub_sn_id]
}

module "asg" {
  source             = "./asg"
  launch_template_id = module.ec2.launch_template_id
  tg_arn             = module.alb.target_group_arn
  lb_id              = module.alb.lb_id
}
