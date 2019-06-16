provider "aws" {
  region = "${var.region}"
}

########################
# EC2 Security Group
########################

resource "aws_security_group" "webapp_security_group" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.application_stack_name}-webapp-security-group"
  }


}

resource "aws_security_group_rule" "ec2_ingress" {
  count = "${length(var.ec2_security_group_ingress)}"

  type = "ingress"
  from_port = "${lookup(var.ec2_security_group_ingress[count.index],"from_port" )}"
  protocol = "${lookup(var.ec2_security_group_ingress[count.index],"protocol" )}"
  to_port = "${lookup(var.ec2_security_group_ingress[count.index],"to_port" )}"
  cidr_blocks = "${split(",",lookup(var.ec2_security_group_ingress[count.index],"cidr_blocks" ) )}"
  security_group_id = "${aws_security_group.webapp_security_group.id}"

}

########################
# Db Security Group
########################


resource "aws_security_group" "db_security_group" {

  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.application_stack_name}-db-security-group"
  }

}


resource "aws_security_group_rule" "db_ingress" {

  count = "${length(var.db_security_group_ingress)}"
  type = "ingress"

  source_security_group_id = "${aws_security_group.webapp_security_group.id}"
  from_port = "${lookup(var.db_security_group_ingress[count.index],"from_port")}"
  protocol = "${lookup(var.db_security_group_ingress[count.index],"protocol" )}"
  to_port = "${lookup(var.db_security_group_ingress[count.index],"to_port" )}"
  security_group_id = "${aws_security_group.db_security_group.id}"


}

########################
# EC2 Instance
########################

resource "aws_instance" "ec2instance" {
  ami = "${var.ec2_instance_values["ami"]}"
  instance_type = "${var.ec2_instance_values["instance_type"]}"
  tenancy = "${var.ec2_instance_values["tenancy"]}"
  disable_api_termination = "${var.ec2_instance_values["disable_api_termination"]}"
  ebs_block_device {
    device_name = "${var.ec2_instance_values["ebs_device_name"]}"
    delete_on_termination = "${var.ec2_instance_values["ebs_delete_on_termination"]}"
    volume_size = "${var.ec2_instance_values["ebs_volume_size"]}"
    volume_type = "${var.ec2_instance_values["ebs_volume_type"]}"

  }
  //  depends_on = [
  //    "aws_db_instance.RDSInstance"]

  subnet_id = "${var.public_subnet_id[0]}"
  vpc_security_group_ids = [
    "${aws_security_group.webapp_security_group.id}"]

  tags {
    Name = "${var.application_stack_name}-ec2-instance"

  }
}


########################
# DB Subnet Group
########################

resource "aws_db_subnet_group" "db_subnet_group" {
  subnet_ids = [
    "${var.public_subnet_id[1]}",
    "${var.public_subnet_id[2]}"]

  tags {
    Name = "${var.application_stack_name}-db-subnet-group"
  }
}


########################
# RDS Instance
########################

resource "aws_db_instance" "RDSInstance" {
  allocated_storage = "${var.db_instance_values["allocated_storage"]}"
  instance_class = "${var.db_instance_values["instance_class"]}"
  multi_az = "${var.db_instance_values["multi_az"]}"
  identifier = "${var.db_instance_values["identifier"]}"
  engine_version = "${var.db_instance_values["engine_version"]}"
  username = "${var.db_instance_values["username"]}"
  password = "${var.db_instance_values["password"]}"
  db_subnet_group_name = "${aws_db_subnet_group.db_subnet_group.id}"
  engine = "${var.db_instance_values["engine"]}"
  publicly_accessible = "${var.db_instance_values["publicly_accessible"]}"
  name = "${var.db_instance_values["name"]}"
  vpc_security_group_ids = [
    "${aws_security_group.db_security_group.id}"]
  skip_final_snapshot = "${var.db_instance_values["skip_final_snapshot"]}"

  tags {
    Name = "${var.application_stack_name}-rds-instance"
  }


}

########################
# DynamoDb Table
########################


resource "aws_dynamodb_table" "dynamoDb" {
  "attribute" {
    name = "${var.dynamoDb_values["attribute_name"]}"
    type = "${var.dynamoDb_values["attribute_type"]}"
  }
  hash_key = "${var.dynamoDb_values["hash_key"]}"
  name = "${var.dynamoDb_values["table_name"]}"
  ttl {
    attribute_name = "${var.dynamoDb_values["ttl_attribute_name"]}"
    enabled = "${var.dynamoDb_values["ttl_enabled"]}"
  }
  read_capacity = "${var.dynamoDb_values["read_capacity"]}"
  write_capacity = "${var.dynamoDb_values["write_capacity"]}"

  tags {
    Name = "${var.application_stack_name}-dynamoDB"
  }

}


