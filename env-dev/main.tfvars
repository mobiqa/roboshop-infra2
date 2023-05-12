env = "dev"
default_vpc_id = "vpc-0ce6a0df3efbac62f"

vpc = {
  main = {
    cidr_block = "10.0.0.0/16"

  }
}

subnets = {
  public = {

    name       = "public"
    vpc_name   = "main"
    cidr_block = ["10.0.0.0/24", "10.0.1.0/24"]
    availability_zone = ["us-east-1a", "us-east-1b"]
    internet_gw       = true


  }
  web = {

    name       = "web"
    vpc_name   = "main"
    cidr_block = ["10.0.2.0/24", "10.0.3.0/24"]
    availability_zone = ["us-east-1a", "us-east-1b"]
    nat_gw       = true
  }
  app = {

    name       = "app"
    vpc_name   = "main"
    cidr_block = ["10.0.4.0/24", "10.0.5.0/24"]
    availability_zone = ["us-east-1a", "us-east-1b"]
    nat_gw       = true
  }
  db = {

    name       = "db"
    vpc_name   = "main"
    cidr_block = ["10.0.6.0/24", "10.0.7.0/24"]
    availability_zone = ["us-east-1a", "us-east-1b"]
    nat_gw       = true
  }
}
