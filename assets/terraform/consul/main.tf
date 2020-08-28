provider "aws" {
  region  = "us-east-1"
  version = "2.63.0"
}

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "/root/terraform/networking/terraform.tfstate"
  }
}

module "consul" {
  source = "./is-immutable-aws-consul"

  ami_owner     = "instruqt@hashicorp.com"
  instance_type = "t3.large"

  consul_cluster_version = var.consul_cluster_version
  bootstrap              = var.bootstrap

  enable_connect = true

  key_name    = "instruqt"
  name_prefix = "instruqt"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc
  subnets     = data.terraform_remote_state.vpc.outputs.private_subnets

  region             = "us-east-1"
  availability_zones = "us-east-1a,us-east-1b,us-east-1c"

  public_ip = false

  consul_nodes     = "3"
  redundancy_zones = false
  performance_mode = false
  enable_snapshots = true

  owner = "instruqt@hashicorp.com"
  ttl   = "-1"

  additional_security_group_ids = [aws_security_group.consul_ssh.id, aws_security_group.consul_lb.id, aws_security_group.consul_servers.id]

  consul_tls_config = module.consul_tls.consul_tls_config

}

module "consul_tls" {
  source            = "./tls-self-signed"
  consul_datacenter = "us-east-1"
  environment_name  = module.consul.env
  dns_names         = [aws_lb.consul.dns_name,"server.azure-central.consul", "server.us-east-1.consul", "localhost"]
}
