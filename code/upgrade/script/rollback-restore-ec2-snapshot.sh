#!/bin/bash

set -o errexit -o pipefail

echo "-------------------------------------------------"
echo " Create an AMI Image from EBS 'ROOT' Snapshot and"
echo " then create an EC2 instance from that image with"
echo " attached EBS 'OPT' Snapshot                     "
echo "-------------------------------------------------"
echo ""

# Note: When creating an AMI image and EC2 instannce, I can not get the dynamic variables 
# working for "block-device-mappings".  So I have it calls the external json files to populate 
# the attributes for this "block-device-mappings".

# These below variables need to be defined first
ROOT_SNAPSHOT_ID=""       # this snapshot id is in the file "root-block-device-mapping.json"
OPT_SNAPSHOT_ID=""        # this snapshot id is in the file "opt-block-device-mapping.json"
IMAGE_NAME=""
IMAGE_DESCRIPTION=""
IMAGE_ARCHITECTURE="x86_64"
IMAGE_ROOT_DEVICE_NAME="/dev/sda1"
IMAGE_VIRTUALIZATION_TYPE="hvm"

INSTANCE_TYPE=""              # m4.2xlarge
INSTANCE_KEY_NAME=""          # 
INSTANCE_SECURITY_GROUP_IDS=""
INSTANCE_SUBNET_ID=""      

# The following variable will be populated from the script below
IMAGE_ID=""     

INSTANCE_DESCRIPTION=""  
INSTANCE_ID=""           
INSTANCE_PRIVATE_IP=""
INSTANCE_PUBLIC_IP=""

# ------------------------------------------------------------------------------------------
# -----------------------Creating an AMI image from first snapshot ('ROOT_SNAPSHOT_ID') ----
# ------------------------------------------------------------------------------------------
# We use the first snapshot 'ROOT_SNAPSHOT_ID' for the AMI because it contains the root device; 
# AMI stores the AMI ID, and we use the snapshot name as the AMI name
echo "Creating an AMI image from first snapshot"

# Caution: No blank spaces after "\" in the command below, otherwise it failed to run
aws_image_id_list=$(aws ec2 register-image \
    --name $IMAGE_NAME \
    --virtualization-type $IMAGE_VIRTUALIZATION_TYPE \
    --architecture $IMAGE_ARCHITECTURE \
    --root-device-name $IMAGE_ROOT_DEVICE_NAME \
    --block-device-mappings file://rollback-root-block-device-mapping.json)

# Get ImageId from the result above
IMAGE_ID=$(echo "$aws_image_id_list" | jq -r '.ImageId')

echo "IMAGE_ID=$IMAGE_ID" 

if [ -z "$IMAGE_ID" ]
then
      echo "\Failed to create an image."
      exit 1
fi

# --------------------------------------------------------------------------
# -----------------------Creating new EC2 instance--------------------------
# --------------------------------------------------------------------------

echo "Creating EC2 instance from this image id '$IMAGE_ID'"

# WARNING: No blank spaces after "\" in the command below, otherwise it failed to run
INSTANCE_DESCRIPTION=$(aws ec2 run-instances --image-id $IMAGE_ID \
    --count 1 \
    --instance-type $INSTANCE_TYPE \
    --key-name $INSTANCE_KEY_NAME \
    --security-group-ids $INSTANCE_SECURITY_GROUP_IDS \
    --subnet-id $INSTANCE_SUBNET_ID \
    --block-device-mappings file://rollback-opt-block-device-mapping.json)

echo "INSTANCE_DESCRIPTION=$INSTANCE_DESCRIPTION"

# -----------------------Getting the ID of the new instance---------------------------
INSTANCE_ID=$(echo $INSTANCE_DESCRIPTION | jq -r '.Instances[].InstanceId')
echo "INSTANCE_ID=$INSTANCE_ID"

if [ -z "$INSTANCE_ID" ]
then
      echo "\Failed to create an instance."
      exit 1
fi

echo "----------------------------------------------------"

#Waiting until the instance is running and displaying its status
# 10 minutes = 600 second = (5*120)
times=0
echo ""
while [ 120 -gt $times ] && ! $(echo $INSTANCE_DESCRIPTION | grep -q "running")
do
  times=$(( $times + 1 ))
  echo "Attempt $times at verifying New Instance Id $INSTANCE_ID is running..."
  sleep 5
  echo "refresh 'INSTANCE_DESCRIPTION' content again"
  INSTANCE_DESCRIPTION=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID)  
done

echo

if [ 600 -eq $times ]; then
  echo "New Instance Id $INSTANCE_ID is not running. Exiting..."
  exit
fi

# Getting the private IP address so we can connect to the instance
INSTANCE_PRIVATE_IP=$(echo $INSTANCE_DESCRIPTION | jq '.Reservations[].Instances[].PrivateIpAddress')
echo ""
echo "INSTANCE_PRIVATE_IP: $INSTANCE_PRIVATE_IP"

# Getting the public IP address so we can connect to the instance
INSTANCE_PUBLIC_IP=$(echo $INSTANCE_DESCRIPTION | jq '.Reservations[].Instances[].PublicIpAddress')
echo ""
echo "INSTANCE_PUBLIC_IP: $INSTANCE_PUBLIC_IP"

echo "Created new instance id '${INSTANCE_ID}' from root snapshot '$ROOT_SNAPSHOT_ID' and opt snapshot '$OPT_SNAPSHOT_ID' successful!!"

exit 0