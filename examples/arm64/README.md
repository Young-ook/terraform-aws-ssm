# AWS Graviton

[AWS Graviton](https://aws.amazon.com/ec2/graviton/) processors are custom built by Amazon Web Services using 64-bit ARM Neoverse cores to deliver the best price performance for you cloud workloads running on Amazon EC2. The new general purpose (M6g), compute-optimized (C6g), and memory-optimized (R6g) instances deliver up to 40% better price/performance over comparable current generation x86-based instances for scale-out and Arm-based applications such as web servers, containerized microservices, caching fleets, and distributed data stores that are supported by the extensive Arm ecosystem. You can mix x86 and Arm based EC2 instances within a cluster, and easily evaluate Arm-based application in existing environments.

## Getting started
[Here](https://github.com/aws/aws-graviton-getting-started) is a github repository for a guide to getting started with AWS Graviton. You can find out more details about how to build, run and optimize your application for AWS Graviton processors.

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-ssm
cd terraform-aws-ssm/examples/arm64
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/arm64/main.tf) is the example of terraform configuration file to create an EC2 instance which is managed by Systems Manager on your AWS account. Check out and apply it using terraform command.

If you don't have the terraform tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-ssm#terraform) of this repository and follow the installation instructions.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file tc1.tfvars
terraform apply -var-file tc1.tfvars
```

## Connect
Move to the EC2 service page on the AWS Management Conosol and select Instances button on the left side menu. Find an instance that you launched. Select the instance and click 'Connect' button on top of the window. After then you will see three tabs EC2 Instance Connect, Session Manager, SSH client. Select Session Manager tab and follow the instruction on the screen.

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
