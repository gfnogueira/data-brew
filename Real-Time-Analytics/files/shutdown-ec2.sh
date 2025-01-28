#!/bin/bash

ec2_name=${1}

if [ -z $ec2_name ]; then 
    echo "Set ec2-name"
    aws ec2 describe-instances \
    --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0]]" \
    --output table
    exit
fi

ec2_id=$(aws ec2 describe-instances \
        --query "Reservations[*].Instances[*].[InstanceId, Tags[?Key=='Name'].Value | [0]]" \
        --output text | grep "$ec2_name" | awk '{print $1}')

aws ec2 stop-instances --instance-ids $ec2_id