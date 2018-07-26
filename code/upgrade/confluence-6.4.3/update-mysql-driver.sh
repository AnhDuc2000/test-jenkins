#Backup old mysql driver
cd /opt
mv /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.34-bin.jar /opt

#Copy new mysql driver
cp mysql-connector-java-5.1.46-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib

#Check file
ls /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5*
