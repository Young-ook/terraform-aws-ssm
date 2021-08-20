# AWS Systems Manager Document

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-ssm
cd terraform-aws-ssm/examples/ssm-document
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/ssm-document/main.tf) is the example of terraform configuration file to create an EC2 instance which is managed by Systems Manager on your AWS account. Check out and apply it using terraform command.

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
