#!/bin/bash

set -o errexit -o pipefail

# Get current directory
CURR_DIR=$(pwd)
echo "CURR_DIR=$CURR_DIR"

# Get Environment variable (DEV, ITG, PROD)
ENVIR=`grep -E "^ENVIR" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "ENVIR=$ENVIR"

# Get NODE1_PRIVATE_IP 
NODE1_PRIVATE_IP=`grep -E "^${ENVIR}_NODE1_PRIVATE_IP" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "NODE1_PRIVATE_IP=$NODE1_PRIVATE_IP"

# Get Confluence download URL
CONFLUENCE_DOWNLOAD_URL=`grep -E "^CONFLUENCE_DOWNLOAD_URL" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "CONFLUENCE_DOWNLOAD_URL=$CONFLUENCE_DOWNLOAD_URL"

# Get CONFLUENCE_UPGRADE_BINARY
CONFLUENCE_UPGRADE_BINARY=`grep -E "^CONFLUENCE_UPGRADE_BINARY" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "CONFLUENCE_UPGRADE_BINARY=$CONFLUENCE_UPGRADE_BINARY"

CONFLUENCE_CURR_VERSION=`grep -E "^CONFLUENCE_CURR_VERSION" "$CURR_DIR"/confluence-upgrade.config | cut -d= -f2`
echo "CONFLUENCE_CURR_VERSION=$CONFLUENCE_CURR_VERSION"

sudo su

# Download Confluence binary file
wget "${CONFLUENCE_DOWNLOAD_URL}/${CONFLUENCE_UPGRADE_BINARY}"

echo "grant executable file"
chmod a+x $CONFLUENCE_UPGRADE_BINARY

# Copy response.varfile to the same location of folder where Confluence binary file located
# This file is needed for running Upgrade with "Unattended upgrade of Confluence"
cp /home/ec2-user/upgrade/response.varfile /opt

# Stop Confluence
echo "Stopping Confluence ..."
service confluence stop

# Wait until java process has stopped before continuing to next step
JAVA_PROCESS_COUNT=0
while [ $JAVA_PROCESS_COUNT -ne 1 ]; do
    JAVA_PROCESS_COUNT=`ps -ef | grep java | wc -l`
    echo "there are $JAVA_PROCESS_COUNT java process running"
    sleep 5
done

# Structure the backup folder name of current Confluence installation (like 'confluence-6.4.3-2019-04-26--15-55-12')
sdt=`date '+%Y-%m-%dT%H-%M-%S'`
BAK_FOLDER="atlassian-confluence-$CURR_CONFLUENCE_VERSION--$sdt"

cd /opt

# backup current Confluence installation by moving it to new folder name
echo "Making a copy of /opt/atlassian to /opt/$BAK_FOLDER"
eval " cp -a /opt/atlassian /opt/$BAK_FOLDER"

#--------------------------------------------------------------
# Start running Upgrade with "Unattended upgrade of Confluence"
#--------------------------------------------------------------
echo "Started running Unattended Upgrade of Confluence"
##### ./$CONFLUENCE_UPGRADE_BINARY -q -varfile response.varfile

#--------------------------------------------------------------
# Future opportunities
#
#  1. Create a "for file in ..." loop to process each file or 
#       a small function. Note: running this script alot would leave
#       lots of dated copies. Idea is to have a generic script that doesn't
#       need lots of editing.
#  2  Separate out restore functionality into a different script.
#       Although, remounting the previous version of /opt/ makes that unnecessary?
#-----------------------------------------------------------------


# backup and restore file 'confluence.cfg.xml'
##### eval " cp /opt/atlassian/confluence-data/confluence.cfg.xml /opt/atlassian/confluence-data/confluence.cfg.xml--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence-data/confluence.cfg.xml /opt/atlassian/confluence-data/confluence.cfg.xml"

# backup and restore file 'server.xml'
##### eval " cp /opt/atlassian/confluence/conf/server.xml /opt/atlassian/confluence/conf/server.xml--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence/conf/server.xml /opt/atlassian/confluence/conf/server.xml"

# backup and restore file 'setenv.sh'
##### eval " cp /opt/atlassian/confluence/bin/setenv.sh /opt/atlassian/confluence/bin/setenv.sh--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence/bin/setenv.sh /opt/atlassian/confluence/bin/setenv.sh"

# restore file 'loginpageoption.vm'
##### eval " cp /opt/$BAK_FOLDER/confluence/confluence/loginpageoption.vm /opt/atlassian/confluence/confluence/loginpageoption.vm"

# backup and restore file 'web.xml'
##### eval " cp /opt/atlassian/confluence/conf/web.xml /opt/atlassian/confluence/conf/web.xml--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence/conf/web.xml /opt/atlassian/confluence/conf/web.xml"

# backup and restore file 'web.xml'
##### eval " cp /opt/atlassian/confluence/confluence/WEB-INF/web.xml /opt/atlassian/confluence/confluence/WEB-INF/web.xml--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence/confluence/WEB-INF/web.xml /opt/atlassian/confluence/confluence/WEB-INF/web.xml"

# backup and restore file 'confluence-init.properties'
##### eval " cp /opt/atlassian/confluence/confluence/WEB-INF/classes/confluence-init.properties /opt/atlassian/confluence/confluence/WEB-INF/classes/confluence-init.properties--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence/confluence/WEB-INF/classes/confluence-init.properties /opt/atlassian/confluence/confluence/WEB-INF/classes/confluence-init.properties"

# backup and restore file 'log4j.properties'
##### eval " cp /opt/atlassian/confluence/confluence/WEB-INF/classes/log4j.properties /opt/atlassian/confluence/confluence/WEB-INF/classes/log4j.properties--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence/confluence/WEB-INF/classes/log4j.properties /opt/atlassian/confluence/confluence/WEB-INF/classes/log4j.properties"

# backup and restore file 'seraph-config.xml'
##### eval " cp /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml--$sdt"
##### eval " cp /opt/$BAK_FOLDER/confluence/confluence/WEB-INF/classes/seraph-config.xml /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml"

# restore file 'mysql-connector-java-5.1.46-bin.jar'
##### eval " cp /opt/$BAK_FOLDER/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.46-bin.jar"

# clean up plugin cache and temp files
echo "Cleaning up cache and temp files"
/home/ec2-user/upgrade/cleanup-file.sh

# now start 
echo "Restarting confluence"
service confluence start

# verify upgrade for any errors
echo "Verifying the upgrade"
/home/ec2-user/upgrade/verify-upgrade.sh $NODE1_PRIVATE_IP


