#!/bin/bash
OUTPUT='.fis_cli_result'
TEMPLATES=('cpu-stress.json' 'network-latency.json' 'terminate-instances.json' 'throttle-ec2-api.json' 'disk-stress.json')
for template in $${TEMPLATES[@]}; do
  aws fis create-experiment-template --region ${region} --output text --cli-input-json file://$${template} --query 'experimentTemplate.id' 2>&1 | tee -a $${OUTPUT}
done
