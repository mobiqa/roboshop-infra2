module "vpc" {
  source         = "github.com/mobiqa/tf-module-vpc2"
  env            =  var.env
  default_vpc_id = var.default_vpc_id


  for_each = var.vpc
  cidr_block = each.value.cidr_block
  public_subnets    = each.value.public_subnets
  private_subnets   = each.value.private_subnets
  availability_zone = each.value.availability_zone

}

module "docdb" {
  source = "github.com/mobiqa/tf-module-docdb2"
  env    = var.env

  for_each       = var.docdb
  subnet_ids     = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnet_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id         = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr     = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine_version = each.value.engine_version
  number_of_instances = each.value.number_of_instances
  instance_class      = each.value.instance_class



}

module "rds" {
  source = "github.com/mobiqa/tf-module-rds2"
  env    = var.env

  for_each            = var.rds
  subnet_ids          = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnet_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id              = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr          = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine              = each.value.engine
  engine_version      = each.value.engine_version
  number_of_instances = each.value.number_of_instances
  instance_class      = each.value.instance_class
}


module "elasticache" {
  source = "github.com/mobiqa/tf-module-elasticache2"
  env    = var.env

  for_each        = var.elasticache
  subnet_ids      = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnet_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id          = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr      = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  num_cache_nodes = each.value.num_cache_nodes
  node_type       = each.value.node_type
  engine_version  = each.value.engine_version
}

module "rabbitmq" {
  source       = "github.com/mobiqa/tf-module-rabbitmq2"
  env          = var.env


  for_each           = var.rabbitmq
  subnet_ids         = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnet_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id             = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr         = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine_type        = each.value.engine_type
  engine_version     = each.value.engine_version
  host_instance_type = each.value.host_instance_type
  deployment_mode    = each.value.deployment_mode
}

module "alb" {
  source = "github.com/mobiqa/tf-module-alb2"
  env    = var.env

  for_each     = var.alb
  subnet_ids   = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), each.value.subnets_type, null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id       = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr   = each.value.internal ? concat(lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "web", null), "cidr_block", null), lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)) : ["0.0.0.0/0"]
  subnets_name = each.value.subnets_name
  internal     = each.value.internal
}



output "vpc" {
  value = module.vpc
}