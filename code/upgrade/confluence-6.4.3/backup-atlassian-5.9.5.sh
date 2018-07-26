cd /opt
mkdir bak-confluence-5.9.5
cp -r atlassian bak-confluence-5.9.5
chown -R confluence:confluence bak-confluence-5.9.5/atlassian/confluence
chown -R confluence:confluence bak-confluence-5.9.5/atlassian/confluence-data
