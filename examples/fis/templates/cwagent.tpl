#!/bin/bash
aws ssm create-association --name AWS-ConfigureAWSPackage \
  --parameters 'action=Install,name=AmazonCloudWatchAgent' \
  --targets 'Key=tag:release,Values=baseline,canary' \
  --region ${region} --output text

sleep 30

aws ssm create-association --name AmazonCloudWatch-ManageAgent \
  --parameters 'action=start' \
  --targets 'Key=tag:release,Values=baseline,canary' \
  --region ${region} --output text
