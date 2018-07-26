#!/bin/bash

echo "List the files in folders before removing"
echo "-----------------------------------------"
ls /opt/atlassian/confluence-data/index
ls /opt/atlassian/confluence-data/journal
ls /opt/atlassian/confluence-data/bundled-plugins
ls /opt/atlassian/confluence-data/plugins-cache
ls /opt/atlassian/confluence-data/plugins-osgi-cache
ls /opt/atlassian/confluence-data/plugins-temp
ls /opt/atlassian/confluence-data/temp
ls /opt/atlassian/confluence-data/logs
ls /opt/atlassian/confluence/logs

#Rebuilding the Content Indexes from Scratch by deleting the content of these two folders
cd /opt/atlassian/confluence-data/index
rm -rf *

#this folder "journal" contains a lot of files so need to delete the whole folder and recreate it.  Otherwise, you might get error
cd /opt/atlassian/confluence-data
rm -rf journal
mkdir journal
chown confluence:confluence journal
chmod 700 journal

#Remove files in plugin cache folders.
cd /opt/atlassian/confluence-data/bundled-plugins
rm -rf *
cd /opt/atlassian/confluence-data/plugins-cache
rm -rf *
cd /opt/atlassian/confluence-data/plugins-osgi-cache
rm -rf *
cd /opt/atlassian/confluence-data/plugins-temp
rm -rf *

#Remove files in temp folder
cd /opt/atlassian/confluence-data/temp
rm -rf *

#       Remove files in Tomcat logs folder and Confluence data logs folder
cd /opt/atlassian/confluence-data/logs
rm -rf *
cd /opt/atlassian/confluence/logs
rm -rf *
#
echo "List the files in the folders after removing"
echo "--------------------------------------------"
ls /opt/atlassian/confluence-data/index
ls /opt/atlassian/confluence-data/journal
ls /opt/atlassian/confluence-data/bundled-plugins
ls /opt/atlassian/confluence-data/plugins-cache
ls /opt/atlassian/confluence-data/plugins-osgi-cache
ls /opt/atlassian/confluence-data/plugins-temp
ls /opt/atlassian/confluence-data/temp
ls /opt/atlassian/confluence-data/logs
ls /opt/atlassian/confluence/logs
#
