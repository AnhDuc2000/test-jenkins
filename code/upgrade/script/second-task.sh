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

# Get NODE1_PUBLIC_IP 
NODE1_PUBLIC_IP=`grep -E "^${ENVIR}_NODE1_PUBLIC_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE1_PUBLIC_IP=$NODE1_PUBLIC_IP"

# Get NODE2_PUBLIC_IP 
NODE2_PUBLIC_IP=`grep -E "^${ENVIR}_NODE2_PUBLIC_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE2_PUBLIC_IP=$NODE2_PUBLIC_IP"

echo "Check and create a directory 'upgrade' under folder /home/ec2-user on node2"
ssh ec2-user@$NODE2_PUBLIC_IP "bash -s" << EOF
    cd /home/ec2-user
    if [ ! -d "upgrade" ]; then
        mkdir upgrade
    fi    
EOF

echo "Send files to node 1"
eval " scp $CURR_DIR/confluence-upgrade.config ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/process-upgraded-node1-to-node2.sh ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/wait-kill-confluence-process.sh ec2-user@$NODE1_PUBLIC_IP:/home/ec2-user/upgrade"

echo "Send files to node 2"
eval " scp $CURR_DIR/process-node2.sh ec2-user@$NODE2_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/verify-upgrade.sh ec2-user@$NODE2_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/cleanup-file.sh ec2-user@$NODE2_PUBLIC_IP:/home/ec2-user/upgrade"
eval " scp $CURR_DIR/wait-kill-confluence-process.sh ec2-user@$NODE2_PUBLIC_IP:/home/ec2-user/upgrade"


echo "Convert DOS script file to unix"
ssh ec2-user@$NODE2_PUBLIC_IP "bash -s" << EOF
    cd /home/ec2-user/upgrade
    dos2unix process-node2.sh
    dos2unix verify-upgrade.sh
    dos2unix cleanup-file.sh
    dos2unix wait-kill-confluence-process.sh
EOF


# Connect to remote server on node 1 and replicate the upgraded Confluence directories to other nodes in the cluster.
ssh ec2-user@$NODE1_PUBLIC_IP "bash -s" << EOF
    pwd
    sudo su
    cd /home/ec2-user/upgrade
    pwd
    echo "Convert files to Unix format"
    
    dos2unix confluence-upgrade.config
    dos2unix process-upgraded-node1-to-node2.sh
    dos2unix wait-kill-confluence-process.sh
        
    echo "Make files executable"

    chmod a+x process-upgraded-node1-to-node2.sh
    
    echo "Now Running process-upgraded-node1-to-node2.sh"
    ./process-upgraded-node1-to-node2.sh
EOF

echo ""
echo "---------------------"
echo "Finish second-task.sh"
echo "---------------------"