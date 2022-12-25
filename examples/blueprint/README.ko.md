[[English](README.md)] [[한국어](README.ko.md)]

# EC2 Bluprint
This is EC2 Blueprint example helps you compose complete EC2 clusters that are fully bootstrapped with the operational software that is needed to deploy and operate workloads. With this EC2 Blueprint example, you describe the configuration for the desired state of your EC2 environment, such as the control plane, worker nodes, and applications, as an Infrastructure as Code (IaC) template/blueprint. Once a blueprint is configured, you can use it to stamp out consistent environments across multiple AWS accounts and Regions using your automation workflow tool, such as Jenkins, CodePipeline. Also, you can use EC2 Blueprint to easily bootstrap an EC2 cluster with user-data for initial configuration whatever you want on your instance. EC2 Blueprints also helps you implement relevant security controls needed to operate workloads from multiple teams in the same cluster.

## 필수 준비사항
이 모듈에서 사용하는 스크립트에서는 웜풀의 변경사항을 조회해서 보여주는 기능을 제공합니다. 이 스크립트 내부에서는 `DescribeScalingActivities` API 응답 JSON 값을 분석하고, 기록된 시간 정보들로부터 작업 시간을 측정하기 위하여 몇 가지 도구를 사용합니다. [jq](https://stedolan.github.io/jq/download/)와 [dateutils](http://www.fresse.org/dateutils/)을 설치합니다.

**macOS**
```
brew install jq dateutils
```

## Setup
### Download
Download this example on your workspace
```
git clone https://github.com/Young-ook/terraform-aws-ssm
cd terraform-aws-ssm/examples/blueprint
```

Then you are in **blueprint** directory under your current workspace. There is an exmaple that shows how to use terraform configurations to create and manage an EC2 cluster and utilities on your AWS account. Check out and apply it using terraform command. If you don't have the terraform and kubernetes tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-ssm) of this repository and follow the installation instructions before you move to the next step.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the *-var-file* option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file fixture.tc1.tfvars
terraform apply -var-file fixture.tc1.tfvars
```

## 컴퓨팅 옵션
### AWS 그래비톤
[AWS 그래비톤](https://aws.amazon.com/ec2/graviton/) 프로세서는 are custom built by Amazon Web Services using 64-bit ARM Neoverse cores to deliver the best price performance for you cloud workloads running on Amazon EC2. The new general purpose (M6g), compute-optimized (C6g), and memory-optimized (R6g) instances deliver up to 40% better price/performance over comparable current generation x86-based instances for scale-out and Arm-based applications such as web servers, containerized microservices, caching fleets, and distributed data stores that are supported by the extensive Arm ecosystem. You can mix x86 and Arm based EC2 instances within a cluster, and easily evaluate Arm-based application in existing environments. Here is a useful [getting started](https://github.com/aws/aws-graviton-getting-started) guide on how to start to use AWS Graviton. This github repository would be good point where to start. You can find out more details about how to build, run and optimize your application for AWS Graviton processors.

## Applications
- [웜풀](./apps/README.ko.md#EC2-오토스케일링-그룹-웜풀)

## 정리
테라폼 실행:
```
terraform destroy
```

If you don't want to see a confirmation question, you can use quite option for terraform destroy command
```
terraform destroy --auto-approve
```

만약 *-var-file* 옵션을 사용해서 자원을 생성했다면, 삭제할 때도 같은 변수를 **반드시** 사용해야 합니다. 꼭 잊지말고 생성할 때 사용한 변수를 지정해서 자원을 삭제합니다.
```
terraform destroy -var-file fixture.tc1.tfvars
```
