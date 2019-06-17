availabilityZone="us-east-1a"
read -p "Enter your CI/CD STACK_NAME: " name
stackName="$name-csye6225-vpc"
read -p "Enter your s3 upload artifact bucket name: " s3
read -p "Enter your s3 upload image bucket name: " imgbucket
ArtifactBucketArn="arn:aws:s3:::s3.$s3/*"
ImageBucketArn="arn:aws:s3:::$imgbucket/*"

read -p "Enter your AWS account ID: " accountid

resource1="arn:aws:codedeploy:us-east-1:$accountid:deploymentconfig:CodeDeployDefault.OneAtATime"
resource2="arn:aws:codedeploy:us-east-1:$accountid:deploymentconfig:CodeDeployDefault.HalfAtATime"
resource3="arn:aws:codedeploy:us-east-1:$accountid:deploymentconfig:CodeDeployDefault.AllAtOnce"
resource4="arn:aws:codedeploy:us-east-1:$accountid:application:CloudDeployApplication"

aws cloudformation create-stack --stack-name $stackName --template-body file://csye6225-cf-ci-cd.json --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=ArtifactBucketArn,ParameterValue=$ArtifactBucketArn ParameterKey=ImageBucketArn,ParameterValue=$ImageBucketArn ParameterKey=Resource1,ParameterValue=$resource1 ParameterKey=Resource2,ParameterValue=$resource2 ParameterKey=Resource3,ParameterValue=$resource3 ParameterKey=Resource4,ParameterValue=$resource4

printf "\n\n"
printf "Creating CI/CD Stack .... Please wait... \n"
printf "\n"
aws cloudformation wait stack-create-complete --stack-name $stackName

printf "\n\n"
if [ $? -eq 0 ]; then
    printf "Stack Created Successfully ...."
else
	printf "Stack Creation Failed "
fi
printf "\n"
