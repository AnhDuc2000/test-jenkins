#!/bin/bash

set -o errexit -o pipefail

echo "------------------------------------------------------------------------"
echo " Find a line contains a string and replace that line with a new string  "
echo "------------------------------------------------------------------------"
echo ""

# Find a line contains a string "confluence.cluster.peers" and replace the whole line with a new string using Sed
new_private_ips="xxx.xx.xx.xxx,yyy.yy.yy.yyy"
find_confluence_cluster_peers="confluence.cluster.peers"
replace_confluence_cluster_peers="   <property name=\"confluence.cluster.peers\">$new_private_ips</property>"
file_location="/opt/atlassian/<confluence data>/confluence.cfg.xml"

echo "Replace new private IPs for 'confluence.cluster.peers'"
eval " sed -i '/$find_confluence_cluster_peers/c\ $replace_confluence_cluster_peers' $file_location"


# Find a line contains a string "hibernate.connection.url" and replace the whole line with a new string using Sed
new_rds_end_point="pentest-confluence-20180712.ceu54difvuaw.us-east-1.rds.amazonaws.com"
find_hibernate_connection_url="hibernate.connection.url"
replace_hibernate_connection_url="   <property name=\"hibernate.connection.url\">jdbc:mysql://$new_rds_end_point/confluence_db</property>"
file_location="/opt/atlassian/<confluence data>/confluence.cfg.xml"

echo "Replace new RDS End Point for 'hibernate.connection.url'"
eval " sed -i '/$find_hibernate_connection_url/c\ $replace_hibernate_connection_url' $file_location"
