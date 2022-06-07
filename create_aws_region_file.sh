#!/bin/bash
AWS_REGION="$1"
USER_SUBNET_ID="$2"
USER_VPC_ID="$3"
USE_PRIVATE_IP="$4"
UI_TFVARS_FILE="$5"
echo "region="\"$AWS_REGION\" >$UI_TFVARS_FILE
echo "user_subnet_id="\"$USER_SUBNET_ID\" >> $UI_TFVARS_FILE
echo "user_vpc_id="\"$USER_VPC_ID\" >> $UI_TFVARS_FILE
echo "use_private_ip="\"$USE_PRIVATE_IP\" >> $UI_TFVARS_FILE
echo "" >> $UI_TFVARS_FILE
