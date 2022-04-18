resource "aws_ssm_association" "install-cwagent" {
  depends_on = [module.ec2]
  name       = "AWS-ConfigureAWSPackage"

  targets {
    key    = "tag:release"
    values = ["baseline,canary"]
  }

  parameters = {
    action = "Install"
    name   = "AmazonCloudWatchAgent"
  }
}

resource "time_sleep" "wait" {
  depends_on      = [aws_ssm_association.install-cwagent]
  create_duration = "30s"
}

resource "aws_ssm_association" "start-cwagent" {
  depends_on = [time_sleep.wait]
  name       = "AmazonCloudWatch-ManageAgent"

  targets {
    key    = "tag:release"
    values = ["baseline,canary"]
  }

  parameters = {
    action = "start"
  }
}
