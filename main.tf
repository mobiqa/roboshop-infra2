module "vpc" {
  source         = "github.com/mobiqa/tf-module-vpc2"
  env            =  var.env
  default_vpc_id = var.default_vpc_id


  for_each = var.vpc
  cidr_block = each.value.cidr_block

}


module "subnets" {
  source         = "github.com/mobiqa/tf-module-subnets2"
  env            =  var.env
  default_vpc_id = var.default_vpc_id


  for_each = var.subnets
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  name              = each.value.name
  vpc_id            = lookup(lookup(module.vpc, each.value.vpc_name, null ), "vpc_id", null)
  vpc_peering_connection_id   = lookup(lookup(module.vpc, each.value.vpc_name, null ), "vpc_peering_connection_id", null)



}


