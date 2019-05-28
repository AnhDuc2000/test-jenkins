#!/bin/bash

set -o errexit -o pipefail

# Initialization phase
echo "Starting initialization"

# Get current directory
CURR_DIR=$(pwd)
echo "CURR_DIR=$CURR_DIR"

# Get Environment variable (DEV, TEST, PROD)
ENVIR=`grep -E "^ENVIR" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "ENVIR=$ENVIR"

# Clone with HTTPS
##### git clone https://github.dxc.com/Platform-DXC/confluence.git

#-----------------------------------
# Opportunity for the future
#
# Use AWS CLI to find the nodes
# Ask user which one to upgrade
#------------------------------------

# Get NODE1_PUBLIC_IP 
NODE1_PUBLIC_IP=`grep -E "^${ENVIR}_NODE1_PUBLIC_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE1_PUBLIC_IP=$NODE1_PUBLIC_IP"

# copy files to remote server to prepare for Confluence upgrade

#-----------------------------------------------------------------------------
# Questions
#  1. If the eval fails will the script stop?
#  2. I think the eval might hide the name of the file being copied? Does it?
#------------------------------------------------------------------------------
eval " scp $CURR_DIR/confluence-upgrade.config ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/response.varfile ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/process-upgrade.sh ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/verify-upgrade.sh ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/cleanup-file.sh ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"

# Connect to remote server on node 1 and run the upgrade.
ssh ec2-user@$NODE1_PUBLIC_IP "bash -s" << EOF
    pwd
    sudo su
    cd /home/ec2-user/upgrade
    pwd
    echo "Convert files to Unix format"

    dos2unix response.varfile
    dos2unix process-upgrade.sh
    dos2unix verify-upgrade.sh
    dos2unix cleanup-file.sh
    
    echo "Make files executable"

    chmod a+x process-upgrade.sh
    chmod a+x verify-upgrade.sh
    chmod a+x cleanup-file.sh

    echo "Now Running process-upgrade.sh"
    ./process-upgrade.sh
EOF

echo "Script finished!!".

