env = "dev"

vpc = {
  main = {
    cidr_block = "10.0.0.0/16"
    subnets_cidr = ["10.0.0.0/16", "10.0.128.0/17" ]
  }
}