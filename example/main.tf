provider "aws" {
  region  = "us-east-1"
    backend "s3" {
    #These configuration points are set in CI as they cannot be set to variables.
    bucket = "mybucket"
    key    = "states/jenkins.state"
    region = "us-east-1"
  } 
}

module "jenkins" {
  source = "github.helix.gsa.gov/GSASecOps/sectools-terraform-jenkins"
  subnet_private_id     = var.subnet_private_id
  vpc_id                = var.vpc_id
  instance_type         = var.instance_type
  instance_name         = var.instance_name
  aws_key_name          = var.aws_key_name
  ami_id                = var.ami_id
  jump_host_cidr_list   = var.jump_host_cidr_list
  app_env               = var.app_evn
  project               = var.project
  ecr_arn               = var.ecr_arn
}