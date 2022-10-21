# AWS Systems Manager
[AWS Systems Manager](https://aws.amazon.com/systems-manager/) gives you visibility and control of your infrastructure on AWS. Systems Manager provides a unified user interface so you can view operational data from multiple AWS services and allows you to automate operational tasks across your AWS resources.

## Examples
- [Bastion host using AWS Session Manager](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/bastion)
- [Bastion host using EIP for allowlist firewall](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/eip)
- [AWS Fault Injection Simulator with AWS Systems Manager](https://github.com/Young-ook/terraform-aws-fis/blob/main/examples/ec2)
- [AWS Fault Injection Simulator with Amazon Elastic Kubernetes Service](https://github.com/Young-ook/terraform-aws-fis/blob/main/examples/eks)
- [AWS Fault Injection Simulator with Amazon ElastiCach for Redis](https://github.com/Young-ook/terraform-aws-fis/blob/main/examples/redis)
- [AWS Fault Injection Simulator with Amazon Relational Database Service](https://github.com/Young-ook/terraform-aws-fis/blob/main/examples/rds)
- [EC2 Autoscaling Warm Pools](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/warm-pools)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

### Terraform
Infrastructure Engineering team is using terraform to build and manage infrastucure for DevOps. And we have a plan to migrate cloudformation termplate to terraform.

To install Terraform, find the appropriate package (https://www.terraform.io/downloads.html) for your system and download it. Terraform is packaged as a zip archive and distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`. The [tfenv](https://github.com/tfutils/tfenv) is very useful solution.

And there is an another option for easy install.
```
brew install tfenv
```
You can use this utility to make it ease to install and switch terraform binaries in your workspace like below.
```
tfenv install 0.12.18
tfenv use 0.12.18
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
tfenv list
tfenv use 0.12.18
tfenv use 0.11.14
tfenv install latest
tfenv use 0.12.18
```

### Setup
```hcl
module "ec2" {
  source  = "Young-ook/ssm/aws"
  name    = "ssm"
  tags    = { env = "test" }
}
```
Run terraform:
```
terraform init
terraform apply
```

## Connect
Move to the EC2 service page on the AWS Management Conosol and select Instances button on the left side menu. Find an instance that you launched. Select the instance and click *Connect* button on top of the window. After then you will see three tabs EC2 Instance Connect, Session Manager, SSH client. Select Session Manager tab and follow the instruction on the screen.

![aws-fis-ec2-disk-stress](images/aws-fis-ec2-disk-stress.png)
