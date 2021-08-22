#!/bin/bash
aws ssm create-association \
  --name Install-CloudWatch-Agent --targets 'Key=tag:env,Values=dev' \
  --region ${region} --output text

sleep 30

aws ssm create-association \
  --name Run-Disk-Stress --targets 'Key=tag:env,Values=dev' \
  --parameters 'DurationSeconds=60,Workers=4,Percent=70' \
  --region ${region} --output text
