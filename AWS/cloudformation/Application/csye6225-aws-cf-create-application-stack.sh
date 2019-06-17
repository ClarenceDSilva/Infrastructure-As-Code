availabilityZone="us-east-1a"
read -p "Enter your Application STACK_NAME : " name
read -p "Enter your S3 bucket : " bucket
read -p "Enter your image S3 bucket : " imagebucket
read -p "Enter your SSL certificate ARN : " certarn
read -p "Enter your DNS Application recordset name : " DNSRecordName
stackName="$name-csye6225-vpc"
s3bucketname="s3.$bucket"



subnet1=$(aws ec2 describe-subnets --filters "Name=defaultForAz,Values=false" "Name=mapPublicIpOnLaunch,Values=true"  --query Subnets[0].SubnetId --output json | tr -d '"')
subnet2=$(aws ec2 describe-subnets --filters "Name=defaultForAz,Values=false" "Name=mapPublicIpOnLaunch,Values=false" --query Subnets[0].SubnetId --output json | tr -d '"')
subnet3=$(aws ec2 describe-subnets --filters "Name=defaultForAz,Values=false" "Name=mapPublicIpOnLaunch,Values=true" "Name=availabilityZone,Values=us-east-1b" --query Subnets[0].SubnetId --output json | tr -d '"')

instanceProfileName=$(aws iam list-instance-profiles --query InstanceProfiles[].InstanceProfileName --output text)

secGrp1=$(aws ec2 describe-security-groups --output text --filters Name=tag-key,Values=Name Name=tag-value,Values=csye6225-webapp --query SecurityGroups[].GroupId)
secGrp2=$(aws ec2 describe-security-groups --output text --filters Name=tag-key,Values=Name Name=tag-value,Values=csye6225-rds --query SecurityGroups[].GroupId)
lbsec=$(aws ec2 describe-security-groups --output text --filters Name=tag-key,Values=Name Name=tag-value,Values=csye6225-loadbalancer --query SecurityGroups[].GroupId)

vpc=$(aws ec2 describe-vpcs --output text --filters "Name=isDefault,Values=false" --query Vpcs[].VpcId)
hostID=$(aws route53 list-hosted-zones --query 'HostedZones[0].Id' --output text | cut -d '/' -f 3)

roleArn=$(aws iam get-role --role-name CodeDeployServiceRole --query Role.Arn --output text)
aws cloudformation create-stack --stack-name  $stackName --template-body file://csye6225-cf-application-stack.json --parameters ParameterKey=S3Bucketname,ParameterValue=$s3bucketname ParameterKey=EC2Instance,ParameterValue=t2.micro ParameterKey=WebServersSecurityGroup,ParameterValue=$secGrp1 ParameterKey=PrivateSubnet,ParameterValue=$subnet2 ParameterKey=PublicSubnet2,ParameterValue=$subnet3 ParameterKey=PublicSubnet,ParameterValue=$subnet1 ParameterKey=InstanceProfileName,ParameterValue=$instanceProfileName ParameterKey=EC2CodeDeploy,ParameterValue=CloudDeploy ParameterKey=EC2tagKey,ParameterValue=EC2tagValue ParameterKey=ImgBucket,ParameterValue=$imagebucket ParameterKey=DbName,ParameterValue=csye6225 ParameterKey=CertArn,ParameterValue=$certarn ParameterKey=RefVpc,ParameterValue=$vpc ParameterKey=ZoneID,ParameterValue=$hostID ParameterKey=LoadBalancerGroup,ParameterValue=$lbsec ParameterKey=DBSecurityGroup,ParameterValue=$secGrp2 ParameterKey=DNSRecordName,ParameterValue=$DNSRecordName ParameterKey=RoleARN,ParameterValue=$roleArn

printf "\n\n"
printf "Creating Application Stack .... Please wait ... \n"
printf "\n"
aws cloudformation wait stack-create-complete --stack-name $stackName

printf "\n\n"
if [ $? -eq 0 ]; then
    printf "Stack Created Successfully ...."
else
	printf "Stack Creation Failed"
fi
printf "\n"
