provider "aws" {
  region = "${var.region}"
}

# S3 bucket for codedeploy artifacts
resource "aws_s3_bucket" "codeDeployBucket" {
  bucket = "${var.S3BucketName}"
  acl    = "private"

}


# IAM roles and policies for EC2 CodeDeploy

resource "aws_iam_role" "CodeDeployEC2ServiceRole" {
  name = "CodeDeployEC2ServiceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }]
}
EOF
}

resource "aws_iam_instance_profile" "CodeDeployEC2ServiceRole" {
  name = "CodeDeploy-EC2-S3-role"	
  role = "${aws_iam_role.CodeDeployEC2ServiceRole.name}"
}


resource "aws_iam_role_policy" "CodeDeployEC2ServiceRole-policy" {
  name        = "CodeDeployEC2ServiceRole-policy"
  role = "${aws_iam_role.CodeDeployEC2ServiceRole.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
			"Effect": "Allow",
			"Action": "*",
			"Resource": "*"
	}
  ]
}
EOF
}

#Adding s3 policy for EC2 to access S3
resource "aws_iam_role_policy" "CodeDeploy-EC2-S3-policy" {
  name = "CodeDeploy-EC2-S3-policy"
  role = "${aws_iam_role.CodeDeployEC2ServiceRole.id}"

policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.codeDeployBucket.arn}"
    }
  ]
}
EOF
}

#Adding CodeDeployServiceRole
resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

  #Attaching CodeDeployServiceRole POLICY to the above role
  resource "aws_iam_role_policy" "CodeDeployServiceRole-policy" {
  name        = "CodeDeployServiceRole-policy"
  role = "${aws_iam_role.CodeDeployServiceRole.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
              {
            "Effect": "Allow",
            "Action": [
                "autoscaling:CompleteLifecycleAction",
                "autoscaling:DeleteLifecycleHook",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:PutLifecycleHook",
                "autoscaling:RecordLifecycleActionHeartbeat",
                "autoscaling:CreateAutoScalingGroup",
                "autoscaling:UpdateAutoScalingGroup",
                "autoscaling:EnableMetricsCollection",
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribePolicies",
                "autoscaling:DescribeScheduledActions",
                "autoscaling:DescribeNotificationConfigurations",
                "autoscaling:DescribeLifecycleHooks",
                "autoscaling:SuspendProcesses",
                "autoscaling:ResumeProcesses",
                "autoscaling:AttachLoadBalancers",
                "autoscaling:PutScalingPolicy",
                "autoscaling:PutScheduledUpdateGroupAction",
                "autoscaling:PutNotificationConfiguration",
                "autoscaling:PutLifecycleHook",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:DeleteAutoScalingGroup",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:TerminateInstances",
                "tag:GetTags",
                "tag:GetResources",
                "sns:Publish",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:PutMetricAlarm",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeInstanceHealth",
                "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
                "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:DeregisterTargets"
            ],
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_codedeploy_app" "CodeDeployApplication" {
  compute_platform = "Server"
  name             = "CodeDeployApplication"
}

resource "aws_codedeploy_deployment_group" "csye6225DeploymentGroup" {
  app_name              = "${aws_codedeploy_app.CodeDeployApplication.name}"
  deployment_config_name = "CodeDeployDefault.OneAtATime"
  deployment_group_name = "csye6225DeploymentGroup"
  service_role_arn      = "${aws_iam_role.CodeDeployServiceRole.arn}"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "EC2tagKey"
      type  = "KEY_AND_VALUE"
      value = "EC2tagValue"
    }
}
}  




