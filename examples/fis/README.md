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

## Create experiment templates
Run script
```
$ ./fis-create-experiments.sh
```
This script creates fault injection simulator experiment templates on the AWS account. Move to the AWS FIS service page on the AWS Management Conosol and select Experiment templates menu on the left. Then users will see the created experiment templates for chaos engineering.
![aws-fis-experiment-templates](../../images/aws-fis-experiment-templates.png)

## Run experiments
To test your environment, select a experiment template that you want to run and click the `Actions` button on the right top on the screen. You will see `Start experiment` in the middle of poped up menu and select it. And follow the instructions.

### CPU Stress
When you successfully start the CPU stress experiment, the CPU utilization of some target instances increases. You can view this metric on the Monitoring tab displayed when the user selects an ec2 instance, or on the CloudWatch service page.

### EC2 instances termination
AWS FIS allows you to test resilience based on ec2 autoscaling group. See what happens when you terminate some ec2 instances in a specific availability zone. This test will check if the autoscaling group launches new instances to meet the desired capacity defined. Use this test to verify that the autoscaling group overcomes the single availability zone failure.

### Throttling AWS API
When running API throttling test, you can see the throttling error when you call the AWS APIs (e.g., DescribeInstances) in the target ec2 instance. Following screenshot shows how it works. First line shows the request and reponse about ec2-describe-instances api using AWS CLI. The error message is `unauthorized` because the target role the instance has does not have right permission to describe instances. And second line is the reponse of the same AWS API call when throttling event is running. You will find out that the error message wil be changed becuase of fault injection.
![aws-fis-throttling-ec2-api](../../images/aws-fis-throttling-ec2-api.png)

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file default.tfvars
```
