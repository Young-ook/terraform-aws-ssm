Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"
#!/bin/bash -x
INSTANCE_ID="`wget -q -O - http://instance-data/latest/meta-data/instance-id`"
REGION="`wget -q -O - http://instance-data/latest/meta-data/placement/region`"
ASG_NAME=$(aws autoscaling describe-auto-scaling-instances --instance-ids $INSTANCE_ID --region $REGION --output text --query 'AutoScalingInstances[*].AutoScalingGroupName')

LC_HOOK_COMPLETE="aws autoscaling complete-lifecycle-action \
        --lifecycle-action-result CONTINUE \
        --instance-id $INSTANCE_ID --region $REGION \
        --auto-scaling-group-name $ASG_NAME --lifecycle-hook-name ${lc_name}"

rpm -q httpd &> /dev/null
if [ $? -ne 0 ]; then
  echo "Application is NOT initialized."
  sudo yum -y install httpd
  sudo systemctl start httpd
  sudo systemctl enable httpd

  ## wait to simulate additional configuration
  for task in {1..12}
  do
    sleep 10
    echo $task
  done
else
  echo "Application is initialized, ready to run."
fi

$LC_HOOK_COMPLETE
--//
