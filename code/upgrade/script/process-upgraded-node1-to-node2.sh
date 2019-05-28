#!/bin/bash

set -o errexit -o pipefail

echo ""
echo "Start replicating the upgraded Confluence directories to other nodes in the cluster"
echo ""

# Get current directory
CURR_DIR=$(pwd)
echo "CURR_DIR=$CURR_DIR"

# Get Environment variable (DEV, TEST, PROD)
ENVIR=`grep -E "^ENVIR" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "ENVIR=$ENVIR"

# Get NODE1_PUBLIC_IP 
NODE1_PUBLIC_IP=`grep -E "^${ENVIR}_NODE1_PUBLIC_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE1_PUBLIC_IP=$NODE1_PUBLIC_IP"

# Get NODE1_PRIVATE_IP 
NODE1_PRIVATE_IP=`grep -E "^${ENVIR}_NODE1_PRIVATE_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE1_PRIVATE_IP=$NODE1_PRIVATE_IP"

# Get NODE2_PUBLIC_IP 
NODE2_PUBLIC_IP=`grep -E "^${ENVIR}_NODE2_PUBLIC_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE2_PUBLIC_IP=$NODE2_PUBLIC_IP"

# Get NODE2_PRIVATE_IP 
NODE2_PRIVATE_IP=`grep -E "^${ENVIR}_NODE2_PRIVATE_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE2_PRIVATE_IP=$NODE2_PRIVATE_IP"

CONFLUENCE_CURR_VERSION=`grep -E "^CONFLUENCE_CURR_VERSION" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "CONFLUENCE_CURR_VERSION=$CONFLUENCE_CURR_VERSION"

# Structure the backup folder name of current Confluence installation (like 'confluence-6.4.3-2019-04-26T15-55-12') - https://en.wikipedia.org/wiki/ISO_8601
sdt=`date '+%Y-%m-%dT%H-%M-%S'`
BAK_SW_FOLDER="atlassian-confluence-sw-$CURR_CONFLUENCE_VERSION--$sdt.tar.gz"
BAK_DATA_FOLDER="atlassian-confluence-data-$CURR_CONFLUENCE_VERSION--$sdt.tar.gz"
BAK_ATLASSIAN_FOLDER="atlassian-$CURR_CONFLUENCE_VERSION--$sdt"

# Check if not root user, then change to root user
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

# Stop Confluence on the first node.
echo "Stopping Confluence ..."
service confluence stop

echo "Wait until Confluence process is stopped before continuing to next step"
./wait-kill-confluence-process.sh

cd /opt

echo "Create a tar file for Confluence software"
tar -czvf $BAK_SW_FOLDER atlassian/confluence

echo "Create a tar file for Confluence data"
tar -czvf $BAK_DATA_FOLDER atlassian/confluence-data

echo "Start Sending tar files to node 2"

eval " scp -i /home/ec2-user/.ssh/id_rsa /opt/$BAK_SW_FOLDER ec2-user@$NODE2_PRIVATE_IP:/home/ec2-user"
eval " scp -i /home/ec2-user/.ssh/id_rsa /opt/$BAK_DATA_FOLDER ec2-user@$NODE2_PRIVATE_IP:/home/ec2-user"


echo "Connect to remote server on node 2 and replicating the upgraded Confluence directories to this node"
ssh -i /home/ec2-user/.ssh/id_rsa ec2-user@$NODE2_PRIVATE_IP "bash -s" << EOF
    /home/ec2-user/upgrade/process-node2.sh $NODE2_PRIVATE_IP $BAK_SW_FOLDER $BAK_DATA_FOLDER $BAK_ATLASSIAN_FOLDER
EOF

# Check if node2 URL is returning {"state":"RUNNING"}
URL_NODE_2="http://$NODE2_PRIVATE_IP:8090/status"
HTTP_RESPONSE_2=$(curl $URL_NODE_2)
echo "HTTP_RESPONSE_2=$HTTP_RESPONSE_2"           
                    
if [[ $HTTP_RESPONSE_2 = *RUNNING* ]]
then
    echo "'$URL_NODE_2' --> $HTTP_RESPONSE_2 --> started up successfully!!"
    
    echo "Node 2 is successfully running"

    # Now restarting node 1
    echo "Restarting confluence on node1"
    service confluence start

    URL_NODE_1="http://$NODE1_PRIVATE_IP:8090/status"

    SLEEP_RUN_INTERVAL=5
    MAX_RUN_INTERVAL=1800
    currSecond=0

    while true; do
        HTTP_RESPONSE_1=$(curl $URL_NODE_1)
        echo "HTTP_RESPONSE_1=$HTTP_RESPONSE_1"           
                        
        if [[ $HTTP_RESPONSE_1 = *RUNNING* ]]
        then
            echo ""
            echo "'$URL_NODE_1' --> $HTTP_RESPONSE_1 --> started up successfully!!"
            break
        fi
        
        currSecond=$(($currSecond + $SLEEP_RUN_INTERVAL))
        echo "Checking Confluence State ... $currSecond"

        if [[ $currSecond -gt $MAX_RUN_INTERVAL ]];
        then
            echo "Quit checking because maximum timeout of trying within $MAX_RUN_INTERVAL"
            break
        fi

        sleep $SLEEP_RUN_INTERVAL

    done
fi

echo "Completed replicating the upgraded Confluence directories to this node"

echo "Finish process-upgraded-node1-to-node2.sh"
