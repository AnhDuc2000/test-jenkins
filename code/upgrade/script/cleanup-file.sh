#!/bin/bash

set -o errexit -o pipefail

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
echo "Rebuilding the Content Indexes from Scratch"

#-----------------------------------------------------
# Question: where does the indexes get rebuilt?
#  Is it from GUI or via a program?
#-----------------------------------------------------
cd /opt/atlassian/confluence-data/index
rm -rf *

#this folder "journal" contains a lot of files so need to delete the whole folder and recreate it.  Otherwise, you might get error
echo "Removing old journal directory"
cd /opt/atlassian/confluence-data
rm -rf journal
mkdir journal
chown confluence:confluence journal
chmod 700 journal

#Remove files in plugin cache folders.
plug_in_dir=/opt/atlassian/confluence-data
echo "Removing files in plugin cache folders in $plug_in_dir"
cd $plug_in_dir

# Suggested update to code
# is the "ls *plugins* too broad" or will it pickup only right directories
for i in `ls *plugins*`
do
   cd $i
   echo "Removing files in $i"
   rm -fr *
done

# Remove files in temp folder
echo "Removing files in temp 
rm -rf /opt/atlassian/confluence-data/temp/*

# Remove files in Tomcat logs folder and Confluence data logs folder
echo "Removing files in Tomcat and Confluence data logs folders"
rm -rf /opt/atlassian/confluence-data/logs/*
rm -rf /opt/atlassian/confluence/logs/*
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
