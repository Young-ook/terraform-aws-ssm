[[English](README.md)] [[한국어](README.ko.md)]

# EC2 블루프린트(Blueprint)
EC2 블루프린트 예제는 EC2 워크로드를 배포하고 운영하기 위해 필요한 소프트웨어를 자동으로 설정하는 과정을 돕는 예제입니다. EC2 블루프린트를 활용하면, 여러 분이 원하는 설정의 EC2 실행환경을 인프라스트럭처 코드(Infrastructure as Code, IaC)의 템플릿/청사진 형태로 만들 수 있습니다. 한 번 블루프린트를 설정했다면, 여러 분은 젠킨스(Jenkins) 또는 코드파이프라인(CodePipeline)과 같은 자동화 도구를 활용하여 필요에 따라 여러 AWS 계정 또는 리전에 같은 환경을 찍어낼 수 있습니다. 또한 여러 분은 EC2 블루프린트를 활용하여 EC2 user-data에 원하는 초기 설정을 등록하여 실행할 수 있습니다. 그리고 EC2 블루프린트는 여러 분이 동일한 클러스터를 여러 팀에게 제공해야 하는 워크로드를 운영해야 할 때 필요한 보안관련 사항들을 쉽게 구축하는 것을 도와줍니다.

## 설치
### 필수요소
이 모듈에서 사용하는 스크립트에서는 웜풀의 변경사항을 조회해서 보여주는 기능을 제공합니다. 이 스크립트 내부에서는 `DescribeScalingActivities` API 응답 JSON 값을 분석하고, 기록된 시간 정보들로부터 작업 시간을 측정하기 위하여 몇 가지 도구를 사용합니다. [jq](https://stedolan.github.io/jq/download/)와 [dateutils](http://www.fresse.org/dateutils/)을 설치합니다.

**macOS**
```
brew install jq dateutils
```

### 내려받기
여러 분의 작업 환경에 예제를 내려받기 합니다.
```
git clone https://github.com/Young-ook/terraform-aws-ssm
cd terraform-aws-ssm/examples/blueprint
```

작업이 끝나면 **blueprint** 디렉토리를 볼 수 있습니다. 디렉토리 안에 있는 예제에는 EC2 클러스터와 추가 요소를 설치하고 관리하기 위한 테라폼(terraform) 설정 파일과 기타 자원이 있습니다. 다음 단계로 넘어가기 전에 테라폼이 제대로 설치 되어 있는 지 확인합니다. 만약, 테라폼이 여러 분의 환경에 없다면, 다음 단계로 이동하기 전에 메인 [페이지](https://github.com/Young-ook/terraform-aws-ssm)의 안내에 따라 설치하시기 바랍니다.

테라폼을 실행합니다:
```
terraform init
terraform apply
```
또는, *-var-file* 옵션을 활용하여 원하는 파라메터를 전달할 수 있습니다.
```
terraform plan -var-file fixture.tc1.tfvars
terraform apply -var-file fixture.tc1.tfvars
```

## 컴퓨팅 옵션
### AWS 그래비톤 (Graviton)
[AWS 그래비톤 (Graviton)](https://aws.amazon.com/ec2/graviton/) 프로세서는 Amazon EC2에서 실행되는 클라우드 워크로드를 최고의 가격 대비 성능을 제공하기 위해 64비트 ARM Neoverse 코어를 사용하여 Amazon Web Services에서 맞춤 제작한 했습니다. 새로운 범용(M6g), 컴퓨팅 최적화(C6g), 메모리 최적화(R6g) 인스턴스는 웹 서버, 컨테이너형 마이크로서비스, 캐싱 플릿, 분산 데이터 스토어와 같은 스케일아웃 및 Arm 기반 애플리케이션을 위해 동급의 현세대 x86 기반 인스턴스 대비 최대 40% 향상된 가격 대비 성능을 제공하며, 광범위한 Arm 에코시스템에서 지원됩니다. 클러스터 내에서 x86 및 Arm 기반 EC2 인스턴스를 혼합할 수 있으며, 기존 환경에서 Arm 기반 애플리케이션을 쉽게 평가할 수 있습니다. 다음은 AWS Graviton 사용을 시작하는 방법에 대한 유용한 [시작하기](https://github.com/aws/aws-graviton-getting-started) 가이드입니다. AWS Graviton 프로세서를 위한 애플리케이션 빌드, 실행 및 최적화 방법에 대한 자세한 내용을 GitHub 저장소의 가이드에서 확인할 수 있습니다.

![aws-graviton2-perf](../../images/aws-graviton2-perf.png)
*source*: [AnandTech](https://www.anandtech.com/show/15578/cloud-clash-amazon-graviton2-arm-against-intel-and-amd)

## 애플리케이션
- [웜풀](./apps/README.ko.md#EC2-오토스케일링-그룹-웜풀)

## 정리
테라폼 실행:
```
terraform destroy
```

삭제 명령을 수행하기 전에 재차 확인하는 과정이 있는데, 이 부분을 바로 넘기려면 테라폼 옵션을 활용할 수 있습니다.
```
terraform destroy --auto-approve
```

**[주의]** 여러 분이 자원을 생성할 때 *-var-file*을 사용했다면, 삭제 할 때에도 반드시 같은 변수 파일을 옵션으로 지정해야 합니다.
```
terraform destroy -var-file fixture.tc1.tfvars
```

# 추가 정보
## Amazon EC2
- [EC2 오토스케일링 웜풀을 활용하여 보다 빠르게 애플리케이션 확대/축소 하기](https://aws.amazon.com/blogs/compute/scaling-your-applications-faster-with-ec2-auto-scaling-warm-pools/)
- [오토스케일링 수명주기와 Lambda, EC2 Run Command 함께 활용하기](https://github.com/aws-samples/aws-lambda-lifecycle-hooks-function)
- [Amazon EC2 오토스케일링 예제](https://github.com/aws-samples/amazon-ec2-auto-scaling-group-examples)
- [신규 – EC2 오토스케일링과 EC2 플릿을 위한 속성 기반 인스턴스 타입 선택 기능](https://aws.amazon.com/blogs/aws/new-attribute-based-instance-type-selection-for-ec2-auto-scaling-and-ec2-fleet/)
- [Amazon EC2 이미지 생성 자동화 예제](https://github.com/aws-samples/amazon-ec2-image-builder-samples)
- [Amazon EBS volumes을 gp2에서 gp3로 변경하여 최대 20% 비용 절감하기](https://aws.amazon.com/blogs/storage/migrate-your-amazon-ebs-volumes-from-gp2-to-gp3-and-save-up-to-20-on-costs/)
- [AWS Systems Manager를 활용하여 비용과 성능 개선을 위한 gp3 전환 자동화하는 방법](https://aws.amazon.com/blogs/apn/how-to-automate-cost-and-performance-improvement-through-gp3-upgrades-using-aws-systems-manager/)

## AWS Graviton
- [AWS Graviton 시작하기](https://github.com/aws/aws-graviton-getting-started)
- [AWS Graviton을 통한 비용 절감과 지속 가능성 증진](https://catalog.workshops.aws/graviton/en-US)

## AWS for Games
- [The Unique Architecture behind Amazon Games’ Seamless MMO New World](https://aws.amazon.com/blogs/gametech/the-unique-architecture-behind-amazon-games-seamless-mmo-new-world/)
