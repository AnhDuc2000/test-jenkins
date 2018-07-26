cd /opt
tar -czvf atlassian-6.4.3-node1.tar.gz atlassian	
scp -i /home/ec2-user/cscdevcloudcustomerzero.pem /opt/atlassian-6.4.3-node1.tar.gz ec2-user@35.153.252.171:/tmp
