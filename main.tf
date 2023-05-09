module "vpc" {
  source         = "github.com/mobiqa/tf-module-vpc2"
  env            =  var.env

  for_each = var.vpc
  cidr_block = each.value.cidr_block
  subnets_cidr = each.value.subnets_cidr

}


