env = "dev"

vpc = {
  main = {
    cidr_block = "10.0.0.0/16"
    subnets_cidr = ["10.0.0.0/18", "10.0.64.0/18" ]
  }
}