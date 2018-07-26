# copy tar file from "/tmp" folder to "/opt" folder
cd /opt
mv /tmp/atlassian-6.4.3-node1.tar.gz .
chown root:root atlassian-6.4.3-node1.tar.gz
tar -xzvf atlassian-6.4.3-node1.tar.gz