variable "region" {

  description = "The Aws region"
  default = "us-east-1"
}

variable "vpc_id" {

  description = "The Aws region"
  default = "us-east-1"
}

variable "public_subnet_id" {
  type = "list"
}


variable "ami" {
  type = "string"
  description = "AMI for Ec2 instance"
  default = "ami-0d729a60"
}

variable "application_stack_name" {
  default = "application"
}

variable "ec2_instance_values" {
  type = "map"
  default = {
    ami = "ami-0d729a60"
    instance_type = "t2.micro"
    tenancy = "default"
    disable_api_termination = "false"
    ebs_device_name = "/dev/sda1"
    ebs_delete_on_termination = true
    ebs_volume_size = 20
    ebs_volume_type = "gp2"
  }

}


variable "db_instance_values" {

  type = "map"
  default = {
    allocated_storage = "20"
    instance_class = "db.t2.medium"
    multi_az = "false"
    identifier = "csye6225-spring2019"
    engine_version = "5.6.37"
    username = "csye6225master"
    password = "csye6225password"
    engine = "MySQL"
    publicly_accessible = true
    name = "csye6225"
    skip_final_snapshot = true
  }
}

variable "dynamoDb_values" {

  type = "map"
  default = {
    attribute_name = "id"
    attribute_type = "S"
    hash_key = "id"
    table_name = "csye6225"
    ttl_attribute_name = "ttl"
    ttl_enabled = true
    read_capacity = "5"
    write_capacity = "5"

  }
}


variable "ec2_security_group_ingress" {
  type = "list"
  default = [

    {

      from_port = 22
      protocol = "tcp"
      to_port = 22
      cidr_blocks = "0.0.0.0/0"
    },
    {

      from_port = 80
      protocol = "tcp"
      to_port = 80
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 443
      protocol = "tcp"
      to_port = 443
      cidr_blocks = "0.0.0.0/0"
    }

  ]

}


variable "db_security_group_ingress" {

  type = "list"
  default = [
    {
      from_port = 3306
      protocol = "tcp"
      to_port = 3306
    }

  ]
}




