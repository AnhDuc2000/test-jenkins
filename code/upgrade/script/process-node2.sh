#!/bin/bash

set -o errexit -o pipefail

NODE2_PRIVATE_IP=$1
BAK_SW_FOLDER=$2
BAK_DATA_FOLDER=$3
BAK_ATLASSIAN_FOLDER=$4

echo "BAK_SW_FOLDER=$BAK_SW_FOLDER"
echo "BAK_DATA_FOLDER=$BAK_DATA_FOLDER"
echo "BAK_ATLASSIAN_FOLDER=$BAK_ATLASSIAN_FOLDER"

# Check if not root user, then change to root user
[ "$UID" -eq 0 ] || exec sudo "$0" "$@"

echo "Stop Confluence on node2"
service confluence stop   

echo "Wait until Confluence process is stopped before continuing to next step"
./wait-kill-confluence-process.sh

echo "Copying a tar file of 'atlassian/confluence' to /opt"
cp $BAK_SW_FOLDER /opt

echo "Copying a tar file of 'atlassian/confluence-data' to /opt"
cp $BAK_DATA_FOLDER /opt  

cd /opt

echo "Move current 'atlassian' folder to another name"
mv atlassian $BAK_ATLASSIAN_FOLDER

echo "Extracting tar file to /opt/atlassian/confluence"
tar -xzvf $BAK_SW_FOLDER

echo "Extracting tar file to /opt/atlassian/confluence-data"
tar -xzvf $BAK_DATA_FOLDER     

#################################################
cd /home/ec2-user/upgrade

##### echo "Wait until Confluence process is stopped before continuing to next step"
##### ./wait-kill-confluence-process.sh

# Reapply any customizations, like JVM properties, from the old version to the new one. 
cd /opt/atlassian/confluence/bin
cp setenv.sh setenv.sh-bak
sed -i 's/name=node1/name=node2/g' setenv.sh

# now start 
echo "Restarting confluence"
service confluence start

# -----------------------------------------------------------
# Check the state of Confluence after started up is "RUNNING"
# -----------------------------------------------------------
# sleep mode in n second before repeating the next loop
SLEEP_RUN_INTERVAL=5

# Maximum of n second for the looping. (1800 second = 30 minutes)
MAX_RUN_INTERVAL=1800

URL_NODE="http://$NODE2_PRIVATE_IP:8090/status"

currSecond=0

while true; do

    HTTP_RESPONSE=$(curl $URL_NODE)
    
    echo "HTTP_RESPONSE=$HTTP_RESPONSE"           
                    
    if [[ $HTTP_RESPONSE = *RUNNING* ]]
    then
        echo ""
        echo "'$URL_NODE' --> $HTTP_RESPONSE --> started up successfully!!"
        #-----------------------------------------------------------------------------------
        # This is where we can perform Confluence Post-Upgrade Checks
        # https://confluence.atlassian.com/doc/confluence-post-upgrade-checks-218272017.html
        # TO DO: 
        #-----------------------------------------------------------------------------------
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

echo "Finish process-node2.sh"
