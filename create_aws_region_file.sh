#!/bin/bash
AWS_REGION="$1"
USER_SUBNET_ID="$2"
UI_TFVARS_FILE="$3"
echo "region="\"$AWS_REGION\" >$UI_TFVARS_FILE
echo "user_subnet_id="\"$USER_SUBNET_ID\" >> $UI_TFVARS_FILE
