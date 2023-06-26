module "vpc" {
  source         = "github.com/mobiqa/tf-module-vpc2"
  env            = var.env
  default_vpc_id = var.default_vpc_id

  for_each          = var.vpc
  cidr_block        = each.value.cidr_block
  public_subnets    = each.value.public_subnets
  private_subnets   = each.value.private_subnets
  availability_zone = each.value.availability_zone
}


module "docdb" {
  source = "github.com/mobiqa/tf-module-docdb2"
  env    = var.env

  for_each            = var.docdb
  subnet_ids          = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnet_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id              = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr          = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)
  engine_version      = each.value.engine_version
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
  source = "github.com/mobiqa/tf-module-rabbitmq2"
  env    = var.env

  bastion_cidr = var.bastion_cidr


  for_each           = var.rabbitmq
  subnet_ids         = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), "private_subnet_ids", null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id             = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr         = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), "private_subnets", null), "app", null), "cidr_block", null)

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
module "apps" {
  source = "github.com/mobiqa/tf-module-app2"
  env    = var.env

  depends_on = [module.docdb, module.rds, module.rabbitmq, module.alb, module.rds, module.elasticache]

  for_each          = var.apps
  subnet_ids        = lookup(lookup(lookup(lookup(module.vpc, each.value.vpc_name, null), each.value.subnets_type, null), each.value.subnets_name, null), "subnet_ids", null)
  vpc_id            = lookup(lookup(module.vpc, each.value.vpc_name, null), "vpc_id", null)
  allow_cidr        = lookup(lookup(lookup(lookup(var.vpc, each.value.vpc_name, null), each.value.allow_cidr_subnets_type, null), each.value.allow_cidr_subnets_name, null), "cidr_block", null)
  alb               = lookup(lookup(module.alb, each.value.alb, null), "dns_name", null)
  listener          = lookup(lookup(module.alb, each.value.alb, null), "listener", null)
  alb_arn           = lookup(lookup(module.alb, each.value.alb, null), "alb_arn", null)
  component         = each.value.component
  app_port          = each.value.app_port
  max_size          = each.value.max_size
  min_size          = each.value.min_size
  desired_capacity  = each.value.desired_capacity
  instance_type     = each.value.instance_type
  listener_priority = each.value.listener_priority

  bastion_cidr = var.bastion_cidr
  monitor_cidr = var.monitor_cidr

}
// Load Test Machine
#resource "aws_spot_instance_request" "load" {
#  instance_type          = "t3.medium"
#  ami                    = "ami-03265a0778a880afb"
#  subnet_id              = "subnet-04b9ddca79d11efbd"
#  vpc_security_group_ids = ["sg-0a9d0bf4249c1bc9e"]
#  wait_for_fulfillment   = true
#}
#
#resource "aws_ec2_tag" "tag" {
#  resource_id = aws_spot_instance_request.load.spot_instance_id
#  key         = "Name"
#  value       = "load-runner"
#}
#
#resource "null_resource" "apply" {
#  provisioner "remote-exec" {
#    connection {
#      host     = aws_spot_instance_request.load.public_ip
#      user     = "root"
#      password = "DevOps321"
#    }
#    inline = [
#      "curl -s -L https://get.docker.com | bash",
#      "systemctl enable docker",
#      "systemctl start docker",
#      "docker pull robotshop/rs-load"
#    ]
#  }
#}
#

#
#module "minikube" {
#  source = "github.com/scholzj/terraform-aws-minikube"
#
#  aws_region        = "us-east-1"
#  cluster_name      = "minikube"
#  aws_instance_type = "t3.medium"
#  ssh_public_key    = "~/.ssh/id_rsa.pub"
#  aws_subnet_id     = element(lookup(lookup(lookup(lookup(module.vpc, "main", null), "public_subnet_ids", null), "public", null), "subnet_ids", null), 0)
#  //ami_image_id        = data.aws_ami.ami.id
#  hosted_zone         = var.hosted_zone
#  hosted_zone_private = false
#
#  tags = {
#    Application = "Minikube"
#  }
#
#  addons = [
#    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/storage-class.yaml",
#    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/heapster.yaml",
#    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/dashboard.yaml",
#    "https://raw.githubusercontent.com/scholzj/terraform-aws-minikube/master/addons/external-dns.yaml"
#  ]
#}
#
#output "MINIKUBE_SERVER" {
#  value = "ssh centos@${module.minikube.public_ip}"
#}
#
#output "KUBE_CONFIG" {
#  value = "scp centos@${module.minikube.public_ip}:/home/centos/kubeconfig ~/.kube/config"
#}

#
#module "eks" {
#  source                 = "github.com/r-devops/tf-module-eks"
#  ENV                    = var.env
#  PRIVATE_SUBNET_IDS     = lookup(lookup(lookup(lookup(module.vpc, "main", null), "private_subnet_ids", null), "app", null), "subnet_ids", null)
#  PUBLIC_SUBNET_IDS      = lookup(lookup(lookup(lookup(module.vpc, "main", null), "public_subnet_ids", null), "public", null), "subnet_ids", null)
#  DESIRED_SIZE           = 2
#  MAX_SIZE               = 2
#  MIN_SIZE               = 2
#  CREATE_PARAMETER_STORE = true
#}
