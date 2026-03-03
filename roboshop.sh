#!/bin/bash

# First we need to know what are the requirements.
# This is the script to create an instance and update the A record in R53.

# create an instance. Based on the requirement like whether it is for frontend or backend. 
# we need to get the public ip for frontend instance and private ip for backend instance.


AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0d35d61ce5afa8d7d"

for instance in $@
do #This is the script to create new instance and get that instance id
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

#This is to know the whether the Ip is public or private

    if [ $instance == "frontend" ]; then
       IP=$( aws ec2 describe-instances \
       --instance-ids $INSTANCE_ID \
       --query 'Reservations[].Instances[].PublicIpAddress]' \
       --output text
       )
    else
      IP=$( aws ec2 describe-instances \
       --instance-ids $INSTANCE_ID \
       --query 'Reservations[].Instances[].PrivateIpAddress]' \
       --output text
        )
    fi
    
    echo "IP address is : $IP"
done




