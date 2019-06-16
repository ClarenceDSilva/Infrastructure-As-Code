variable "region" {

  description = "The AWS region"
  default = "us-east-1"
}

#S3 bucket for Code Deploy
variable "S3BucketName" {
	description = "AWS bucket"
	default = "csye6225-codedeploy"
}
