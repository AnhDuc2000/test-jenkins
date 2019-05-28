#!/bin/bash

set -o errexit -o pipefail

NODE1_PRIVATE_IP=$1

# Start time to record the time when starting Confluence
START_CONFLUENCE_TIME=`date '+%Y-%m-%d %H:%M:%S'`

# sleep mode in n second before repeating the next loop
SLEEP_RUN_INTERVAL=5

# Maximum of n second for the looping. (1800 second = 30 minutes)
MAX_RUN_INTERVAL=1800

#
# Confluence Upgrade
#
# 0=true;  1=false;
IS_BUILD_NUMBER_MATCH=0
IS_UPGRADE_COMPLETED=1
IS_START_UP_SUCCESSFUL=1
IS_MYSQL_JDBC_EXCEPTION_ERROR=1

STATUS_SUCCESS=0
STATUS_FAILED=1

CONFLUENCE_APP_LOG=/opt/atlassian/confluence-data/logs/atlassian-confluence.log
#CONFLUENCE_APP_LOG=/d/aws-dxc/User-Story/Confluence-Upgrade-6.15.2/confluence-upgrade-script/atlassian-confluence.log

# Search for --> atlassian-confluence.log:2018-07-22 21:18:37,303 INFO [localhost-startStop-1] [atlassian.confluence.upgrade.AbstractUpgradeManager] entireUpgradeFinished Upgrade completed successfully
function checkUpgradeStatus {
    local upgradeSuccessMsg="entireUpgradeFinished Upgrade completed successfully"    
    local entireUpgradeFinished=$(grep "$upgradeSuccessMsg" "$CONFLUENCE_APP_LOG" | tail -1)

    # use -n --> the length is non-zero
    if [ -n "$entireUpgradeFinished" ]; then
        local dateTime=${entireUpgradeFinished:0:19}        # extract dateTime from the string
        if [ "$dateTime" \> "$START_CONFLUENCE_TIME" ]      # if date time is later than the time to start confluence, then it is valid
        then
            IS_UPGRADE_COMPLETED=0        
        fi
    fi
}

# https://confluence.atlassian.com/confkb/confluence-will-not-start-up-because-the-build-number-in-the-home-directory-doesn-t-match-the-build-number-in-the-database-after-upgrade-376834096.html?_ga=2.255840904.149078102.1556203270-1686289218.1553280628
# Check if there is the build number in the Home Directory doesn't match the build number in the Database, after upgrade
# Search for --> 2013-06-04 07:53:32,448 ERROR [main] [atlassian.confluence.setup.BootstrapApplicationStartupListener] checkConfigurationOnStartup Confluence will not start up because the build number in the Home Directory [<build number>] doesn't match the build number in the Database [<build number>].
function checkBuildNumber {
    local buildErrorMsg="doesn't match the build number in the Database"        
    if grep -q "$buildErrorMsg" "$CONFLUENCE_APP_LOG"; then
        IS_BUILD_NUMBER_MATCH=1        
    fi    
}

# Search for --> 2019-04-22 20:48:06,331 INFO [localhost-startStop-1] [com.atlassian.confluence.lifecycle] init Confluence is ready to serve
function checkStartUp {
    local startUpSuccessMsg="init Confluence is ready to serve"    
    local initConfluenceIsReadyToServe=$(grep "$startUpSuccessMsg" "$CONFLUENCE_APP_LOG" | tail -1)
    
    # use -n --> the length is non-zero
    if [ -n "$initConfluenceIsReadyToServe" ]; then
        local dateTime=${initConfluenceIsReadyToServe:0:19}     # extract dateTime from the string
        if [ "$dateTime" \> "$START_CONFLUENCE_TIME" ]          # if date time is later than the time to start confluence, then it is valid
        then
            IS_START_UP_SUCCESSFUL=0        
        fi
    fi
}

# Search for --> com.mysql.jdbc.exceptions
function checkMySQLExceptionError {
    local jdbcExceptionMsg="com.mysql.jdbc.exceptions"    
    local mySqlJdbcExeptionError=$(grep "$jdbcExceptionMsg" "$CONFLUENCE_APP_LOG" | tail -1)

    # use -n --> the length is non-zero
    if [ -n "$mySqlJdbcExeptionError" ]; then
        IS_MYSQL_JDBC_EXCEPTION_ERROR=0
    fi
}

# Search Atlassian Confluence Log for upgrade status, start up successful, and build number matching
function checkConfluenceLog {
    local currSecond=1
    while [ $currSecond -le $MAX_RUN_INTERVAL ]; do
        checkUpgradeStatus
        checkBuildNumber
        checkMySQLExceptionError
        checkStartUp
    
        currSecond=$(($currSecond + $SLEEP_RUN_INTERVAL))

        echo "Verifying the Confluence log ... $currSecond"
        
        # Check if Build number does not match;
        if [ $IS_BUILD_NUMBER_MATCH -eq $STATUS_FAILED ] 
        then           
            echo "BREAK --> Check if Build number does not match;"
            break

        # Check if start up message successful.
        elif [ $IS_START_UP_SUCCESSFUL -eq $STATUS_SUCCESS ]
        then            
            echo "BREAK --> Check if start up message successful"
            break

        # Check if upgrade message is success
        elif [ $IS_UPGRADE_COMPLETED -eq $STATUS_SUCCESS ]
        then
            echo "BREAK --> Check if upgrade message is success"
            break
        fi
    
        sleep $SLEEP_RUN_INTERVAL

    done
    echo
    echo    
    echo "checkUpgradeStatus() -----> "
    if [ $IS_UPGRADE_COMPLETED -eq $STATUS_SUCCESS ]
    then    
        echo "SUCCESSFUL: entireUpgradeFinished Upgrade completed successfully!!" 
    else
        echo "FAILED: Upgrade failed." 
    fi
    echo

    echo "checkBuildNumber() -----> "
    if [ $IS_BUILD_NUMBER_MATCH -eq $STATUS_FAILED ]
    then
        echo "FAILED: Build number does not match." 
    else
        echo "SUCCESSFUL: build number matching!!"
    fi
    echo
    
    echo "checkMySQLExceptionError() -----> "
    if [ $IS_MYSQL_JDBC_EXCEPTION_ERROR -eq $STATUS_SUCCESS ]
    then
        echo "FAILED: There is error about 'com.mysql.jdbc.exceptions'"  
    else
        echo "SUCCESSFUL: There is no error found about 'com.mysql.jdbc.exceptions'"  
    fi
    echo

    echo "checkStartUp() -----> "
    if [ $IS_START_UP_SUCCESSFUL -eq $STATUS_SUCCESS ]
    then
        echo "SUCCESSFUL: Confluence started up successful!!"  
    else
        echo "FAILED: Confluence failed to start up."  
    fi
    echo
}

# ---------------------------------------------------
# Main process to verify upgrade is starting here 
# ---------------------------------------------------

# Wait until file exist
while [ ! -f "$CONFLUENCE_APP_LOG" ]; do
    echo "$CONFLUENCE_APP_LOG does not exist"
    sleep 5
done

if [ -f "$CONFLUENCE_APP_LOG" ]; then
    # Start verifying
    echo "Start verifying confluence log"
    checkConfluenceLog
    
    # -----------------------------------------------------------
    # Check the state of Confluence after started up is "RUNNING"
    # -----------------------------------------------------------
    URL_NODE="http://$NODE1_PRIVATE_IP:8090/status"
    
    currSecond=1
    
    while true; do

        HTTP_RESPONSE=$(curl $URL_NODE)
        
        echo "HTTP_RESPONSE=$HTTP_RESPONSE"           
                     
        if [[ $HTTP_RESPONSE = *RUNNING* ]]
        then
            echo ""
            echo "'$URL_NODE' --> $HTTP_RESPONSE --> started up successful!!"
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
fi        

