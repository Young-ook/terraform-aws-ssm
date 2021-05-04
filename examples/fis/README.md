# AWS Fault Injection Simulator
## Setup
[This](https://github.com/Young-ook/terraform-aws-ssm/blob/main/examples/fis/main.tf) is an example of terraform configuration file to create AWS Fault Injection Simulator experiments for chaos engineering. Check out and apply it using terraform command.

Run terraform:
```
$ terraform init
$ terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
$ terraform plan -var-file default.tfvars
$ terraform apply -var-file default.tfvars
```

## Create experiments
Run script
```
$ ./fis-create-experiments.sh
```
Move to the AWS FIS service page on the AWS Management Conosol and select Experiment templates menu on the left. You will see the created experiment templates for fault injection test of EC2 resources.

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
