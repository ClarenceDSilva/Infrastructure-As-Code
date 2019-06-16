variable "region" {

  description = "The Aws region"
  default = "us-east-1"
}

variable "networkStackName" {

  default = "network"
}

variable "vpcCIDR" {

  default = "10.0.0.0/16"
}

variable "subnetNumbers" {
  type = "map"
  description = "Map from availability zone to the CIDR block that should be used for each availability zone's subnet"
  default = {
    "us-east-1a" = "10.0.1.0/24"
    "us-east-1b" = "10.0.3.0/24"
    "us-east-1c" = "10.0.5.0/24"
  }
}

variable "destinationCIDR" {
  default = "0.0.0.0/0"
}