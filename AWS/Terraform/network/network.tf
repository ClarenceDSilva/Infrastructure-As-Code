provider "aws" {
  region = "${var.region}"
}


resource "aws_vpc" "csye6225-vpc" {
  cidr_block = "${var.vpcCIDR}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "${var.networkStackName}-csye6225-vpc"

  }
}

resource "aws_subnet" "public-subnet" {
  count = "${length(var.subnetNumbers)}"

  vpc_id = "${aws_vpc.csye6225-vpc.id}"
  cidr_block = "${element(values(var.subnetNumbers), count.index)}"
  availability_zone = "${element(keys(var.subnetNumbers), count.index)}"

  tags {
    Name = "${var.networkStackName}-csye6225-public-subnet-${count.index}"
  }
}


resource "aws_internet_gateway" "network-internet-gateway" {

  vpc_id = "${aws_vpc.csye6225-vpc.id}"

  tags {
    Name = "${var.networkStackName}-csye6225-internet-gateway"

  }
}


resource "aws_route_table" "network-route-table" {
  vpc_id = "${aws_vpc.csye6225-vpc.id}"

  tags {
    Name = "${var.networkStackName}-route-table"

  }

}


resource "aws_route" "public-route" {

  route_table_id = "${aws_route_table.network-route-table.id}"
  destination_cidr_block = "${var.destinationCIDR}"
  gateway_id = "${aws_internet_gateway.network-internet-gateway.id}"
  depends_on = [
    "aws_internet_gateway.network-internet-gateway"]


}

resource "aws_route_table_association" "public-subnet" {
  count = "${length(var.subnetNumbers)}"
  subnet_id = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.network-route-table.id}"

}


########################
# Outputs
########################

output "vpc_id" {
  value = "${aws_vpc.csye6225-vpc.id}"
}


output "public_subnets" {
  description = "List of IDs of public subnets"
  value = [
    "${aws_subnet.public-subnet.*.id}"]
}

