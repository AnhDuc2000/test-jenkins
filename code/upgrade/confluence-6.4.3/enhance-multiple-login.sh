#Copy "loginpageoption.vm" to destination folder
cp /opt/loginpageoption.vm /opt/atlassian/confluence/confluence

#backup "seraph-config.xml"
cp /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml-orig

#update "seraph-config.xml".  This file must be updated first and store at folder /opt
cp /opt/seraph-config.xml /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml
