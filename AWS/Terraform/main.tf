module "network" {

  source = "./network"
}


module "application" {
  source = "./application"
  vpc_id = "${module.network.vpc_id}"
  public_subnet_id = "${module.network.public_subnets}"

}