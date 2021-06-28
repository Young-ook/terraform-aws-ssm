# AWS Systems Manager
[AWS Systems Manager](https://aws.amazon.com/systems-manager/) gives you visibility and control of your infrastructure on AWS. Systems Manager provides a unified user interface so you can view operational data from multiple AWS services and allows you to automate operational tasks across your AWS resources.

## Examples
- [Bastion host using AWS Session Manager](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/bastion)
- [AWS Fault Injection Simulator with AWS Systems Manager](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/fis)
- [AWS Fault Injection Simulator with Amazon Elastic Kubernetes Service](https://github.com/Young-ook/terraform-aws-eks/blob/main/examples/fis)

## Getting started
### AWS CLI
Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

### Terraform
Infrastructure Engineering team is using terraform to build and manage infrastucure for DevOps. And we have a plan to migrate cloudformation termplate to terraform.

To install Terraform, find the appropriate package (https://www.terraform.io/downloads.html) for your system and download it. Terraform is packaged as a zip archive and distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

And there is an another option for easy install. The [tfenv](https://github.com/tfutils/tfenv) is very useful solution.
You can use this utility to make it ease to install and switch terraform binaries in your workspace like below.
```
$ tfenv install 0.12.18
$ tfenv use 0.12.18
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
$ tfenv list
$ tfenv use 0.12.18
$ tfenv use 0.11.14
$ tfenv install latest
$ tfenv use 0.12.18
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
$ terraform init
$ terraform apply
```
