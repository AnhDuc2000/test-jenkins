# Implementation Plan for Upgrading Confluence

## Send Notification to the users

## Update Banner
- You can use this as reference https://confluence.atlassian.com/confkb/how-to-add-a-site-wide-banner-165609599.html

## Install the Font Config
```sudo yum install fontconfig```
## Do the EFS rsync 45 min
- Make sure both the current EFS and the Backup EFS are mounted in the node03
- Stop the cron job
- Run the rsync
- Restart the cron job

## Preconfigurations
### Update JAVA_HOME to /usr/lib/jvm/jdk8u212-b03 in confluence service script /etc/init.d/confluence 3 mins
### Update /opt/atlassian/confluence/bin/setenv.sh
- Add at the end CATALINA_OPTS="-Dconfluence.upgrade.recovery.file.enabled=false ${CATALINA_OPTS}" 2 min
### Update confluence.cfg.xml
- Change line <property name="hibernate.c3p0.max_size">60</property> 2 min
### Run the clean file
- /opt/atlassian/confluence-data/cleanup-file.sh 1 min

## Running the Upgrade Script on node01
- Stop confluence on node 2
- Run Upgrade Script first-task.sh 10 min
- Take the DB snapshot 10 mins
- Run service confluence start 10 min 
- Verify the startup execution 5 min
```
grep "entireUpgradeFinished Upgrade completed successfully" atlassian-confluence.log
curl http://172.31.75.93:8090/status
```
## Manual Changes 30 min
Update /opt/atlassian/confluence/bin/setenv.sh
- change memory CATALINA_OPTS="-Xms1024m -Xmx4096m -XX:+UseG1GC ${CATALINA_OPTS}"
- add node name CATALINA_OPTS="-Dconfluence.cluster.node.name=node1 ${CATALINA_OPTS}" 

## Update /opt/atlassian/confluence/conf/server.xml
- Replace server connection with
```
<Connector port="8090" connectionTimeout="20000" redirectPort="8443"
                proxyName="confluencepentest.dxcdevcloud.net"
                proxyPort="443"
                scheme="https"
                secure="false"
                maxThreads="48" minSpareThreads="10"
                enableLookups="false" acceptCount="10" debug="0" URIEncoding="UTF-8"
                protocol="org.apache.coyote.http11.Http11NioProtocol" />
```
## Update /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml 
- Comment line 5 and add ```<param-value>/loginpageoption.vm</param-value>```
- Comment line 10 and add ```<param-value>/loginpageoption.vm</param-value>```
- Add session timeout
```
<!-- This property sets the default remember me cookie max age in seconds.  Force it to expire in 5 second -->
        <init-param>
            <param-name>autologin.cookie.age</param-name>
            <param-value>5</param-value>
        </init-param>
```
## Update /opt/atlassian/confluence/confluence/WEB-INF/web.xml
- change  ```<session-timeout>30</session-timeout>```
- comment ```<!-- <tracking-mode>COOKIE</tracking-mode> -->```

## Time for validations 5 min
- Start the service once again
- try to login https://confluencepentest.dxcdevcloud.net/
- JIRA Pentest Domain https://jirapentest.dxcdevcloud.net
- Make sure the user base can syncronize

## Enable Plugins (might need to clean-file.sh and restart service)
- Comala Workflows
- Draw.io
- WebDav
- Widget Connector
- Office Connector Plugin

## Run second-task.sh to upgrade node 2, time 30 mins

## Verify if there is more than one process confluence
```top -u confluence```

# Roll Back
## RDS 10 min:
- Restore RDS snapshot to a db instance

## EC2 10 min:
- Rename
    - /opt/atlassian to somename
- Rename 
    - /opt/<backup atlassian> to /opt/atlassian
- Change the new db url in "/opt/atlassian/confluence-data/confluence.cfg.xml"
- Change the file "/etc/init.d/confluence" and using below export
```export JAVA_HOME=/usr/java/default```
## EFS 3 min:
- Rename confluence.cfg.xml --> confluence.cfg.xml--6.15.2

## Restart Confluence and confirm it is working as expected 10 min

## Send Notification to the users

## Update Banner
