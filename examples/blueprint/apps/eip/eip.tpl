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
AZ="`wget -q -O - http://instance-data/latest/meta-data/placement/availability-zone`"
EIP_ALLOC_ID=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=eipAllocId" --region=$REGION --output=text | cut -f5)

aws ec2 associate-address --instance-id $INSTANCE_ID --allocation-id $EIP_ALLOC_ID --allow-reassociation --region=$REGION --output=text
--//
