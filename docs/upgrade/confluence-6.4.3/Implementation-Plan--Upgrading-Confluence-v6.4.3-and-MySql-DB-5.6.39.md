# Implementation Plan for upgrading Confluence v6.4.3 and MySql Db v5.6.39

This implementation plan is for upgrading Confluence v5.9.5 to v6.4.3 and MySql Db v5.6.27 to v5.6.39 on production.  Plus configure the Global Pass with the new integrated SAML Authentication within Confluence.

| Task Name                                                                                                        | Duration (minutes) | Start (pm) | End (pm) | Remark                        |
| ---------------------------------------------------------------------------------------------------------------- | ------------------ | ---------- | -------- | ----------------------------- |
| AWS Production Information                                                                                       | 0                  |            |          |                               |
| Pre-upgrade                                                                                                      | 0                  |            |          |                               |
| -----	a. Perform the health checks (this can be done in advance before startint MTP) (1 min)                     | 1                  |            |          |                               |
| -----	b. Create a new parameter group (done in advance) (5 min)                                                  | 5                  |            |          |                               |
| -----	c. Perform Confluence Update Check (1 min)                                                                 | 1                  |            |          |                               |
| 0. Assumptions                                                                                                   | 0                  | 3:00       |          | MTP Start at 3pm PST          |
| 1. Backup atlassian folder (Continue without waiting for this complete) (3 min)                                  | 3                  | 3:00       | 3:03     |                               |
| 2. Perform screen captures and DB queries (5 min)                                                                | 5                  | 3:03       | 3:08     | a & b in parallel             |
| -----	a. Capture screen for "Confluence Usage" (1 min)                                                           | 1                  |            |          |                               |
| -----	b. Run DB queries (5 min)                                                                                  | 5                  |            |          |                               |
| 3. Back up (40 min)                                                                                              | 40                 | 3:08       | 3:48     | 3 & 4 can be done in parallel |
| -----	a. Stop the cluster (1 min)                                                                                | 1                  |            |          |                               |
| -----	b. Back up rsynch (40 min)                                                                                 | 40                 |            |          |                               |
| -----	c. perform snapshot of xvda and xvdb (4 min, in parallel with efs)                                         | 4                  |            |          |                               |
| 4. Perform MySQL database upgrade (50 min)                                                                       | 50                 | 3:08       | 3:58     | 3 & 4 can be done in parallel |
| -----	a. Perform snapshot of DB (5 min)                                                                          | 5                  |            |          |                               |
| -----	b. Change DB version with new parameter group "confluence-mysql" (33)                                      | 33                 |            |          |                               |
| -----	c. Run DB queries and compare with pre db upgrade (5 min)                                                  | 5                  |            |          |                               |
| -----	d. Start Confluence on node 1 (5 min)                                                                      | 5                  |            |          |                               |
| 5. Clear old add-on cache, index, and temp files (3 min)                                                         | 3                  | 3:58       | 4:01     |                               |
| -----	a. Shutdown Confluence on Node 1 (1 min)                                                                   | 1                  |            |          |                               |
| -----	b. Deleting the content of the indexes, old add-on cache and temp files (2 min)                            | 2                  |            |          |                               |
| 6. Upgrade Confluence – Node 1 (1 hr + 15 min)                                                                   | 75                 | 4:01       | 5:16     |                               |
| -----	a. Perform upgrade on 1st node (10 min)                                                                    | 10                 |            |          |                               |
| -----	b. For MySQL database, replace the latest jdbc driver and backup older one. (1 min)                        | 1                  |            |          |                               |
| -----	c. Reapply any customizations, like JVM properties, from the old version to the new one. (3 min)           | 3                  |            |          |                               |
| -----	d. Start Confluence. During this step, your database will be upgraded. (28 min)                            | 28                 |            |          |                               |
| -----	e. Global Pass – upgrade SAML Configuration (15 minutes) – need GP team onboard                            | 15                 |            |          |                               |
| -----	f. Upgrade Confluence plugins to the supported versions. (3 min)                                           | 3                  |            |          |                               |
| -----	g. Post-Upgrade Checklist and other integration test (15 min)                                              | 15                 |            |          |                               |
| 7. Upgrade Confluence – Node 2 (20 min)                                                                          | 20                 | 5:16       | 5:36     |                               |
| -----	a. Stop Confluence on the first node                                                                       | 1                  |            |          |                               |
| -----	b. Copy the installation directory and local home directory from the first node to the next node. (10 min) | 10                 |            |          |                               |
| -----	c. Start Confluence on second node, and confirm that you can log in and view pages on this node            |                    |            |          |                               |
| -----	d. Post-Upgrade Checklist on Node 2 (10 min)                                                               | 15                 |            |          |                               |
| 8. Final testing (30 min)                                                                                        | 30                 | 5:36       | 6:06     |                               |
| 9. Back-out Plan (30 min)                                                                                        | 30                 |            |          |                               |
| 10. Coordination Needed                                                                                          |                    |            |          |                               |


## AWS Production Information
VPC:	vpc-5b49163f - csc-devcloud-os-customer-zero
Zone:	us-east-1a

  | Type | Name           | Elastic IP  | Public IP  | Private IP  | Public DNS (IPv4)  |
  | -----|:-------------:| -----:|
  | ec2  | confluence-node01-prod | 52.73.177.83 | 52.73.177.83 | 10.0.0.197 | ec2-52-73-177-83.compute-1.amazonaws.com |
  | ec2  | confluence-node02-prod | 35.153.252.171 | 35.153.252.171 | 10.0.0.245 | ec2-35-153-252-171.compute-1.amazonaws.com |
  | ec2  | confluence-node03-prod-backup |  | 54.210.129.196 | 10.0.0.90 | ec2-54-210-129-196.compute-1.amazonaws.com |
  | efs  | confluence-efs |  |  | 10.0.0.72 |  |
  | rds  | cz-mysqldb |  |  |  |  |

## Pre-upgrade
	node 1:
		copy the following files on the folder "/opt"
			atlassian-confluence-6.4.3-x64.bin
			mysql-connector-java-5.1.46-bin.jar

	node 2:
		copy this file below on the folder "/home/ec2-user" for ssh copying the files from node 1 to node 2
			cscdevcloudcustomerzero.pem

	Putty
		Need to have two terminals for node 1 and two terminals for node 2 open

		Need to have 1 terminal connecting to "confluence-node03-prod-backup--ec2-user@54.210.129.196" to do rsyn

	AWS
		Need to log in AWS prod on RDS, EC2
        https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstances:
        https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:search=confluence;sort=instanceId


### Complete the pre-upgrade checks
##### a. Perform the health checks (this can be done in advance before startint MTP) (0 min)
              Go to "Confluence administration" > General Configuration > Atlassian Support Tools
                (https://confluence.csc.com/plugins/servlet/stp/view/)
                Problems Detected > Database > InnoDB Log File Size
                  Result: Your innodb_log_file_size of 134,217,728 is too small. You should increase innodb_log_file_size to 256M.
                  Resolve: On AWS, create a new parameter group and set the following
                      Set innodb_log_file_size to 512M
                        (https://confluence.atlassian.com/confkb/mysqlsyntaxerrorexception-row-size-too-large-658735905.html?utm_campaign=stp-health-checks-beta&utm_medium=stp-jdk-health-check&utm_source=stp)

                Problems Detected > Database > WarningMax Allowed Packets
                  Result: Your packet size of 4,194,304 is too small. You should increase max_allowed_packets to 34M.
                  Resolve: On AWS, create a new parameter group and set the following
                      Set max_allowed_packet to 512M

##### b. Create a new parameter group (done in advance) (5 min)
                              On AWS, go to RDS > Parameter groups	(https://console.aws.amazon.com/rds/home?region=us-east-1#parameter-groups:)
                                Click on "Create parameter group" button
                      			       Parameter group family = "mysql5.6"
                      			       Group name = "confluence-mysql"
                      			       Description = "Customize parameter group for MySQL to use by Confluence"

                      			       Click on "Create"

                      		      Search for "confluence-mysql" and make the following changes
                      			       Change parameter value of "innodb_log_file_size" to 536870912	(512M)
                      			       change parameter value of "max_allowed_packet" to 536870912 	(512M )


##### c. Perform Confluence Update Check (this can be done in advance before startint MTP) (0 min)
              Go to "Confluence administration" > "Manage add-ons" > "Confluence Update Check" > "Check compatibility for update to" > "Select 6.4.3 and click "Check" button to check the compatibility of the add-ons.
                (https://confluence.csc.com/plugins/servlet/upm/check?source=manage)
                    Disable “SAML SingleSignOn for Confluence”


### 0.	Assumptions
---------------
	•	Start time = 3pm Pacific (3:30am IST)

### 1. Backup atlassian folder (Continue without waiting for this complete) (3 min) (3pm -> 3:01pm Pac)
    Copy atlassian folder to folder bak-confluence-5.9.5, because some of information from previous version still needed after upgraded
        Putty to Confluence node 1 “52.73.177.83” (10.0.0.197)
        sudo su
        cd /opt
        ./backup-atlassian-5.9.5.sh
            ** The content of this bash script
                cd /opt
                mkdir bak-confluence-5.9.5
                cp -r atlassian bak-confluence-5.9.5
                chown -R confluence:confluence bak-confluence-5.9.5/atlassian/confluence
                chown -R confluence:confluence bak-confluence-5.9.5/atlassian/confluence-data

### 2. Perform screen captures and DB queries (5 min)

##### a. Capture screen for "Confluence Usage" (1 min)
				(https://confluence.csc.com/admin/systeminfo.action)
					Search for "Confluence Usage"
					Take a screenshot of it

##### b. Run DB queries (5 min)
			Go to Windows Jump Server "ec2-54-89-151-235.compute-1.amazonaws.com"
          Run the queries are located under folder "C:\Users\Administrator\Documents\sql\confluence" which are listed in below

          Save the result of each query in the following folders.
              C:\Users\Administrator\Documents\sql\confluence\report\1-Before-DB-Upgrade
              C:\Users\Administrator\Documents\sql\confluence\report\2-After-DB-Upgrade
              C:\Users\Administrator\Documents\sql\confluence\report\3-After-Confluence-Upgrade

          User Atom software pre-installed on the server to compare files.

            			> 1-List of users who assigned to spaces and groups  (1 mins)
                      		SELECT spacename, spacekey, group_name, lower_user_name, email_address, LAST_LOG_IN FROM (
                                SELECT distinct s.spacename, s.spacekey, g.group_name, u.lower_user_name, u.email_address, DATE_FORMAT(l.successdate, '%Y-%m-%d') AS LAST_LOG_IN
                                  FROM SPACEPERMISSIONS sp
                                    JOIN SPACES s ON s.spaceid = sp.spaceid
                                    JOIN cwd_group g ON sp.permgroupname = g.group_name
                                    JOIN cwd_membership m ON g.id = m.parent_id
                                    JOIN cwd_user u ON m.child_user_id = u.id
                                    JOIN user_mapping um ON um.username = u.lower_user_name
                                    JOIN logininfo l ON um.user_key = l.username
                                  WHERE
                                    g.group_name <> 'confluence-users'
                                    AND g.ACTIVE = 'T'
                                    AND u.ACTIVE = 'T'
                                UNION
                                SELECT distinct s.spacename, s.spacekey, '' group_name, u.lower_user_name, u.email_address, DATE_FORMAT(l.successdate, '%Y-%m-%d') AS LAST_LOG_IN
                                  FROM SPACES s
                                   JOIN SPACEPERMISSIONS p ON s.SPACEID = p.SPACEID
                                   JOIN user_mapping m ON p.PERMUSERNAME = m.user_key
                                   JOIN cwd_user u ON m.username = u.lower_user_name
                                   JOIN logininfo l ON m.user_key = l.username
                                   WHERE u.ACTIVE = 'T'
                              ) a
                          order by spacename, spacekey, group_name, lower_user_name;

            			> 2-List Number of pages in a space ( < 1 min)
                          select SPACES.SPACENAME, count(CONTENTID) as 'number of pages' from CONTENT join SPACES on CONTENT.SPACEID = SPACES.SPACEID where CONTENT.SPACEID is not null and CONTENT.PREVVER is null and CONTENT.CONTENTTYPE = 'PAGE' group by SPACES.SPACENAME order by SPACES.SPACENAME;

            			> 3-List number of attachment size in a spaces ( < 1 min)
                          select s.spacename , sum(cp.LONGVAL) from SPACES s INNER JOIN CONTENT c ON c.spaceid = s.spaceid INNER JOIN CONTENTPROPERTIES cp ON cp.contentid = c.contentid where c.contenttype = 'ATTACHMENT' and cp.propertyname = 'FILESIZE' GROUP BY s.spacename;

            			> 4-List all tables with row count ( < 1 mins)
            						  This is a long query.  See this file "List all tables with row counts.sql" in this server at "C:\Users\Administrator\Documents\sql\confluence"


### 3. Back up (40 min)

##### a. Stop the cluster (1 min)
		Putty to Confluence node 1 “52.73.177.83” (10.0.0.197)
			sudo su
			service confluence stop

		Putty to Confluence node 2 “35.153.252.171” (10.0.0.245)
			sudo su
			service confluence stop

##### b. Back up rsynch (40 min)
			puty to confluence-node03-prod-backup--ec2-user@54.210.129.196 (54.210.129.196)
				sudo su
				cd /usr/local/bin
				./confluence-rsync-efs.sh

##### c. perform snapshot of xvda and xvdb (4 min, in parallel with efs)
			Node1:
				Take snapshot of confluence-node01-prod root  -- confluence-node01-prod-new -- vol-bdd98219 -- 80 GiB
					(https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-bdd98219;sort=desc:createTime)
						--> Action --> Create Snapshot
								Description:  confluence-node01-prod-ebs-volume-sda1-root
								Tag:
										Key: 	Name;
										Value: 	confluence-node01-prod-ebs-volume-sda1-root

				Take snapshot of confluence-node01-prod opt  -- confluence-node01-prod-new -- vol-74da81d0 -- 100 GiB
					(https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-74da81d0;sort=desc:createTime)
						--> Action --> Create Snapshot
								Description:  confluence-node01-prod-ebs-volume-sdb-opt
								Tag:
										Key: 	Name;
										Value: 	confluence-node01-prod-ebs-volume-sdb-opt


			Node2:
				Take snapshot of confluence-node02-prod root  -- confluence-node02-prod-new -- vol-0de1a38ce41034c1b -- 80 GiB
					(https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-0de1a38ce41034c1b;sort=desc:createTime)
						--> Action --> Create Snapshot
								Description:  confluence-node02-prod-ebs-volume-sda1-root
								Tag:
										Key: 	Name;
										Value: 	confluence-node02-prod-ebs-volume-sda1-root

				Take snapshot of confluence-node02-prod opt  -- confluence-node02-prod-ebs-xvdb-opt -- vol-0eff49e243c56dbb8 -- 100 GiB
					(https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-0eff49e243c56dbb8;sort=desc:createTime)
						--> Action --> Create Snapshot
								Description:  confluence-node02-prod-ebs-volume-sdb-opt
								Tag:
										Key: 	Name;
										Value: 	confluence-node02-prod-ebs-volume-sdb-opt

### 4. Perform MySQL database upgrade (50 min)
** Make sure the database is not "backing up" status
##### a. perform snapshot of DB (5 min, in parallel with efs)
					(https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstance:id=cz-mysqldb)
						--> Instance actions --> Take snapshot --> Snapshot name: cz-mysqldb-v5-6-27-d2018-08-03

							Note: you might see the message "backup-up" under >>>> RDS > Instances
##### b. Change DB version with new parameter group "confluence-mysql" (30 min upgrade + 3 min reboot to apply update db parameter option)
       	  On AWS, goto RDS > Instances	(https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstances:)
       	  Find "cz-mysqldb" and click on it
       	  Scroll down to the middle of the page and click on "Modify" button

          Change "DB engine version"
       		   From: mysql 5.6.27
       		   To:   mysql 5.6.39 (default)

          Change "DB parameter group"
       		   From:  default.mysql5.6
       		   To:	  confluence-mysql

       	  Click on "Continue" button

       	  Select "Apply immediately"

       		   Summary of Modifications
       			    You are about to submit the following modifications. Only values that will change are displayed. Carefully verify your changes and click Modify DB Instance.

               			Attribute		         Current Value		         New Value
               			---------		         -------------		         ---------
               			DB engine version	   5.6.27 (MySQL 5.6.27)	   5.6.39 (mysql 5.6.39)
               			DB parameter group	 default.mysql5.6	         confluence-mysql

       	     Click on "Modify DB Instance", you will see the status of these below
                Note:
                    RDS > Instances -- you will see status = "upgrading" (22 min)
                    RDS > Instances -- you will see status = "modifying" (1 min)
                    RDS > Snapshots -- you will see status = "creating"  (navigate to the last page to see this)

            When you see in the parameter group with the status of "confluence-mysql (pending-reboot)", then perform in below to reboot.
                Select "cz-mysqldb"
                Click on "Instance actions" --> "Reboot" --> "Reboot" button
                    Status: rebooting (12:28am -- 12:29am)
                    After the status of db is "Available", in the "parameter group" it should said "cz-mysqldb (in-sync)"

##### c. Run DB queries and compare with pre db upgrade (5 min)
    Run the DB queries at step 2-b and save the result at C:\Users\Administrator\Documents\sql\confluence\report\2-After-DB-Upgrade
        1-List of users who assigned to spaces and groups.csv
        2-List Number of pages in a space.csv
        3-List number of attachment size in a spaces.csv
        4-List all tables with row count.csv

    compare these results with the previous ran db queries from step 2-b at this folder using Atom software with compare file package
        C:\Users\Administrator\Documents\sql\confluence\report\1-Before-DB-Upgrade

##### d. Start Confluence on node 1 (5 min)
    Putty to node 1 and start Confluence (3 min)
        service confluence start

        ***Make sure no major errors in the Atlassian log.  You might see the Hipchat error.

        On Confluence, check "Instance Health" (1 min)
              Go to "Confluence administrator"
              Click on "Support Tools" (https://confluence.csc.com/plugins/servlet/stp/view/)
              Click on "Instance health" tab
                  Make sure very thing is passed checks especially database.

        On Confluence, go to "Space Directory" and try to navigate to any spaces and confirm it is working fine. (1 min)
            Click on Confluence Home Page (Confluence Dashboard)
            Click on "Spaces" --> "Space directory"
               (https://confluence.csc.com/spacedirectory/view.action)


**Go/No-go Decision on MySQL Upgrade**
		•	If not satisfied with MySQL upgrade, revert back to original snapshot and continue below (10m)
			   Will have to change the Confluence configuration file "confluence.cfg.xml" to point to the original instance db (See Back-out Plan – Database – 7.1).
		•	Otherwise, continue below

### 5. Clear old add-on cache, index, and temp files (4 min)
##### a. Shutdown Confluence on Node 1 (1 min)
        service confluence stop

##### b. Deleting the content of the indexes, old add-on cache and temp files (2 min)
        cd /opt/
        ./cleanup-file.sh
              This batch file "clean-file.sh" contains the following
                    #!/bin/bash
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

### 6. Upgrade Confluence – Node 1 (1 hr + 30 min for GP + 2 min for add-ons)
##### a. Perform upgrade on 1st node (8 min)
  Make sure you don't have any opened sessions currently under folder "/opt/*".
	Make sure there is not any backup file in the "/opt/atlassian/confluence-data/temp".  Otherwise it will take a lot of time for backing up the confluence folders during upgrade process

	Perform upgrade on 1st node
      			Putty to Confluence node 1
      				sudo su
      				cd /opt
              [root@ip-xxx-xx-xx-xx opt]# ./atlassian-confluence-6.4.3-x64.bin
                    Unpacking JRE ...
                    Starting Installer ...
                    Jul 22, 2018 8:07:34 PM java.util.prefs.FileSystemPreferences$2 run
                    INFO: Created system preferences directory in java.home.

                    This will install Confluence 6.4.3 on your computer.
                    OK [o, Enter], Cancel [c]

                    Choose the appropriate installation or upgrade option.
                    Please choose one of the following:
                    Express Install (uses default settings) [1],
                    Custom Install (recommended for advanced users) [2],
                    Upgrade an existing Confluence installation [3, Enter]
                    3
                    Existing installation directory:
                    [/opt/atlassian/confluence]

                    Back Up Confluence Home
                    The upgrade process will automatically back up your Confluence Installation
                    Directory. You can also choose to back up your existing Confluence Home
                    Directory. Both directories are backed up as zip archive files in their
                    respective parent directory locations.

                    We strongly recommend choosing this option in the unlikely event that you
                    experience problems with the upgrade and may require these backups to
                    restore your existing Confluence installation.

                    If you have many attachments in your Confluence Home Directory, the zip
                    archive of this directory may consume a significant amount of disk space.
                    Back up Confluence home ?
                    Yes [y, Enter], No [n]
                    y

                    Checking for local modifications.

                    List of modifications made within Confluence directories.

                    The following provides a list of file modifications within the confluence
                    directory.

                    Modified files:
                            confluence/WEB-INF/web.xml
                            bin/setenv.sh
                            conf/server.xml
                            conf/web.xml
                    Removed files:
                            (none)
                    Added files:
                            confluence/WEB-INF/lib/mysql-connector-java-5.1.34-bin.jar
                            confluence/printheader.jsp
                            jre/bin/ssl_certificate.p7b
                            bin/setenv.sh.old
                            conf/server.xml.old
                            conf/server1.xml

                    [Enter]


                    Checking if your instance of Confluence is running
                    Upgrade Check List
                    Back up your external database
                    We strongly recommend you back up your Confluence database if you have not
                    already done so.

                    Please refer to the following URL for back up guidelines:
                    http://docs.atlassian.com/confluence/docs-64/Production+Backup+Strategy

                    Check plugin compatibility
                    Check that your non-bundled plugins are compatible with Confluence 6.4.3.

                    For more information see our documentation at the following URL:
                    http://docs.atlassian.com/confluence/docs-64/Installing+and+Configuring+Plugins+using+the+Universal+Plugin+Manager


                    Please ensure you have read the above checklist before upgrading.
                    Your existing Confluence installation is about to be upgraded! Do you want to proceed?
                    Upgrade [u, Enter], Exit [e]
                    u

                    Your instance of Confluence is currently being upgraded.
                    Checking if Confluence has been shutdown...
                    Backing up the Confluence installation directory

                    Backing up the Confluence home directory

                    Deleting the previous Confluence installation directory...

                    Extracting files ...


                    Please wait a few moments while we configure Confluence.
                    Installation of Confluence 6.4.3 is complete
                    Start Confluence now?
                    Yes [y, Enter], No [n]
                    n
                    Installation of Confluence 6.4.3 is complete
                    Custom modifications
                    Your previous Confluence installation contains customisations (eg
                    server.xml) that must be manually transferred. Refer to our documentation
                    more information:
                    http://docs.atlassian.com/confluence/docs-64/Upgrading+Confluence#UpgradingConfluence-custommodifications
                    Finishing installation ...


      				chmod a+x atlassian-confluence-6.4.3-x64.bin
      				./atlassian-confluence-6.4.3-x64.bin
      					Unpacking JRE ...
      					Starting Installer ...

      					This will install Confluence 6.4.3 on your computer.
      					OK [o, Enter], Cancel [c]

      					Choose the appropriate installation or upgrade option.
      					Please choose one of the following:
      					Express Install (uses default settings) [1],
      					Custom Install (recommended for advanced users) [2],
      					Upgrade an existing Confluence installation [3, Enter]
      					3
      					Existing installation directory:
      					[/opt/atlassian/confluence]

      					Back Up Confluence Home
      					The upgrade process will automatically back up your Confluence Installation
      					Directory. You can also choose to back up your existing Confluence Home
      					Directory. Both directories are backed up as zip archive files in their
      					respective parent directory locations.

      					We strongly recommend choosing this option in the unlikely event that you
      					experience problems with the upgrade and may require these backups to
      					restore your existing Confluence installation.

      					If you have many attachments in your Confluence Home Directory, the zip
      					archive of this directory may consume a significant amount of disk space.
      					Back up Confluence home ?
      					Yes [y, Enter], No [n]
      					y

      					Checking for local modifications.

      					List of modifications made within Confluence directories.

      					The following provides a list of file modifications within the confluence
      					directory.

      					Modified files:
      							confluence/WEB-INF/web.xml
      							bin/setenv.sh
      							conf/server.xml
      							conf/web.xml
      					Removed files:
      							(none)
      					Added files:
      							confluence/printheader.jsp
      							confluence/WEB-INF/lib/mysql-connector-java-5.1.34-bin.jar
      							bin/setenv.sh.old
      							conf/server.xml.old
      							conf/server1.xml
      							jre/bin/ssl_certificate.p7b

      					[Enter]


      					Checking if your instance of Confluence is running
      					Upgrade Check List
      					Back up your external database
      					We strongly recommend you back up your Confluence database if you have not
      					already done so.

      					Please refer to the following URL for back up guidelines:
      					http://docs.atlassian.com/confluence/docs-64/Production+Backup+Strategy

      					Check plugin compatibility
      					Check that your non-bundled plugins are compatible with Confluence 6.4.3.

      					For more information see our documentation at the following URL:
      					http://docs.atlassian.com/confluence/docs-64/Installing+and+Configuring+Plugins+using+the+Universal+Plugin+Manager


      					Please ensure you have read the above checklist before upgrading.
      					Your existing Confluence installation is about to be upgraded! Do you want to proceed?
      					Upgrade [u, Enter], Exit [e]
      					u

      					Your instance of Confluence is currently being upgraded.
      					Checking if Confluence has been shutdown...
      					Backing up the Confluence installation directory

      					Backing up the Confluence home directory

      					Deleting the previous Confluence installation directory...

      					Extracting files ...


      					Please wait a few moments while we configure Confluence.
      					Installation of Confluence 6.4.3 is complete
      					Start Confluence now?
      					Yes [y, Enter], No [n]
      					n
      					Installation of Confluence 6.4.3 is complete
      					Custom modifications
      					Your previous Confluence installation contains customisations (eg
      					server.xml) that must be manually transferred. Refer to our documentation
      					more information:
      					http://docs.atlassian.com/confluence/docs-64/Upgrading+Confluence#UpgradingConfluence-custommodifications
      					Finishing installation ...

##### b. For MySQL database, replace the latest jdbc driver and backup older one. (1 min)
    Run bash script
    cd /opt
    ./update-mysql-driver.sh
        ** This bash script contains in below
            #Backup old mysql driver
            cd /opt
            mv /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.34-bin.jar /opt

            #Copy new mysql driver
            cp mysql-connector-java-5.1.46-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib

            #Check file
            ls /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5*

##### c. Reapply any customizations, like JVM properties, from the old version to the new one. (3 min)
    Find different
        diff /opt/atlassian/confluence/bin/setenv.sh /opt/bak-confluence-5.9.5/atlassian/confluence/bin/setenv.sh

    Modify Tomcat files
    		vi /opt/atlassian/confluence/bin/setenv.sh
    			Change:
    				From:	CATALINA_OPTS="-Xms1024m -Xmx1024m -XX:+UseG1GC ${CATALINA_OPTS}"
    				To:	CATALINA_OPTS="-Xms1024m -Xmx4096m -XX:+UseG1GC ${CATALINA_OPTS}"

    			Add:
    					CATALINA_OPTS="-Dconfluence.cluster.node.name=node1 ${CATALINA_OPTS}"
    					CATALINA_OPTS="-Dconfluence.upgrade.recovery.file.enabled=false ${CATALINA_OPTS}"

    			Modify Confluence file
    				vi /opt/atlassian/confluence/conf/server.xml
    					Change:
    						<Connector port="8090" connectionTimeout="60000" redirectPort="8443"
    							proxyName="confluence.csc.com"
    							proxyPort="443"
    							scheme="https"
    							secure="true"
    							maxThreads="48" minSpareThreads="10"
    							enableLookups="false" acceptCount="10" debug="0" URIEncoding="UTF-8"
    							protocol="org.apache.coyote.http11.Http11NioProtocol" />

      Increase the maximum backup log file to 25 so we can have more records of history activities about Confluence 6.4.3 upgrade.
            vi /opt/atlassian/confluence/confluence/WEB-INF/classes/log4j.properties
                change:
                    From: log4j.appender.confluencelog.MaxBackupIndex=5
                    To: log4j.appender.confluencelog.MaxBackupIndex=25

##### d. Start Confluence. During this step, your database will be upgraded. (13 min finished task upgrade + 15 min to check for any errors in the logs and db query results)

    i. Start Confluence and check for any errors in the logs (15 min)
        Run this command as root
              service confluence start

        Check Tomcat log file for any errors
            tail -f /opt/atlassian/confluence/logs/catalina.out

      	Check Confluence log file for any errors
        		tail -f /opt/atlassian/confluence-data/logs/atlassian-confluence.log


                After you have completed an upgrade, you should see the following message in the atlassian-confluence.log file:
                  	2010-03-08 08:03:58,899 INFO [main] [atlassian.confluence.upgrade.AbstractUpgradeManager]
                  					atlassian-confluence.log:2018-07-22 21:18:11,221 INFO [localhost-startStop-1] [atlassian.confluence.upgrade.AbstractUpgradeManager] initialUpgradeFinished Upgrade initial stage completed successfully

                  				(after 1 min, you should see below message)
                  					atlassian-confluence.log:2018-07-22 21:18:37,303 INFO [localhost-startStop-1] [atlassian.confluence.upgrade.AbstractUpgradeManager] entireUpgradeFinished Upgrade completed successfully

                If you do not see the line in your log similar to the one above, this means that your upgrade may not have completed successfully. Please check our Upgrade Troubleshooting https://confluence.atlassian.com/confkb/upgrade-troubleshooting-180847191.html documentation to check for a suitable recommendation or fix.  In this case, we need to make the decision to roll back or continue.

                **Note: During the upgrade process, you might see the warning message "java.lang.OutOfMemoryError: Java heap space".  Do not terminate the process and wait for its process to finished, This might take a few minutes.  This error does not occur if you have below setup in "setenv.sh"
                        CATALINA_OPTS="-Dconfluence.upgrade.recovery.file.enabled=false ${CATALINA_OPTS}"

                **If you see this error in Confluence UI "Confluence cluster node will not start up because the build number in the database [6212] doesn't match either the application build number [7402] or the home directory build number [7402].", it means the upgrade is not successful.  See here for the fix https://confluence.atlassian.com/confkb/confluence-will-not-start-up-because-the-build-number-in-the-home-directory-doesn-t-match-the-build-number-in-the-database-after-upgrade-376834096.html.  In this case, we need to make the decision to roll back or continue.

    ii. Check MySQL DB using this "select * from CONFVERSION;" to confirm all the previous versions upgraded successfully like in below (< 1 min)

        					CONFERSIONID	BUILDNUMBER	INSTALLDATE				VERSIONTAG							***VERSION***
        					622593		6212		2016-02-24 05:54:57		lock_for_upgrade_to_7402				5.9.5
        					113672193	6403		2018-07-15 06:31:51
        					113672194	6406		2018-07-15 06:31:51
        					113672195	6412		2018-07-15 06:31:51
        					113672196	6439		2018-07-15 06:33:01
        					113672197	7101		2018-07-15 06:33:03																		6.0.1
        					113672198	7104		2018-07-15 06:33:04																		6.0.6
        					113672199	7105		2018-07-15 06:33:05
        					113672200	7108		2018-07-15 06:33:06
        					113672201	7109		2018-07-15 06:33:06																	  6.1.x
        					113672202	7110		2018-07-15 06:33:06																		6.1.4
        					113672203	7202		2018-07-15 06:33:06																		6.3.x
        					113672204	7402		2018-07-15 06:33:07																		6.4.x

    iii. Check "confluence.cfg.xml" and confirm the build number 7402 is the same as on the database (< 1 min)
        				vi /opt/atlassian/confluence-data/confluence.cfg.xml
        					   <buildNumber>7402</buildNumber>

    iv. Run the DB queries at step 2-b and save the result at C:\Users\Administrator\Documents\sql\confluence\report\3-After-Confluence-Upgrade (5 min)
             1-List of users who assigned to spaces and groups.csv
             2-List Number of pages in a space.csv
             3-List number of attachment size in a spaces.csv
             4-List all tables with row count.csv

         compare these results with the previous ran db queries from step 4-b at this folder "2-After-DB-Upgrade" using Atom software with "Split Diff" package

    v. Check Clustering (< 1 min)
    		Go to "Confluence administrator"
    		Click on "Clustering"  (https://confluence.csc.com/plugins/servlet/cluster-monitoring)
    		Confirm Node name "node1" is currently running

    vi. Check "Instance Health" (< 2 min)
    		Go to "Confluence administrator"
    		Click on "Support Tools" (https://confluence.csc.com/plugins/servlet/stp/view/)
    		Click on "Instance health" tab
        Make sure very thing is passed checks.

        		 Except "Administration" is failed because we use an user "Administrator" instead of "admin" and both Internal directory and Jira directory have same account of "Administrator".
                  Result: Confluence has an enabled internal user directory, however its administrator account does not exist or is disabled
                  Resolution: For this check to pass Confluence will need to be using an SSO solution or:
                        1. An Internal User Directory that is active.
                        2. A System Admin User in that Internal Directory.
                          (https://confluence.atlassian.com/confkb/health-check-internal-administrator-user-829068290.html)
                          (https://www.redradishtech.com/display/KB/Reordering+User+Directories+in+JIRA+and+Confluence)

        	Check System Information
        				Go to "Confluence administrator"
        				Click on "System Information"
        					 Confluence Version: 6.4.3
        					 Build Number: 7402
        					 Database version: 5.6.39-log
        					 Database Driver Version: mysql-connector-java-5.1.46

	 vii. On Confluence, go to "Space Directory" and try to navigate to any spaces and confirm it is working fine (< 3 min)
			   Click on Confluence Home Page (Confluence Dashboard)
			   Click on "Spaces" --> "Space directory"
				      (https://confluence.csc.com/spacedirectory/view.action)

    viii. Check and confirm re-Index automatically started right after 1 or 2 min from this message "init Confluence is ready to serve" on Node 1 (40 min)
          Go to "Confluence administrator"
          Select "Content Indexing"
          Click on "Search Indexes" and confirm the index is running
              (https://Confluence.csc.com/secure/admin/IndexAdmin.jspa)

##### e. Global Pass – upgrade SAML Configuration (15 minutes) – need GP team onboard
				i.	Configure SAML Configuration with Global Pass metadata (ACS url, Entity ID, certificate)
                Go to "Confluence administration"
                Click on "SAML Authentication" on the left menu
                      Authentication method:  checked "SAML single sign-on"
                      Single sign-on issuer:  urn:federation:csc
                      Identity provider single sign-on URL: https://gpl.amer.csc.com/affwebservices/public/saml2sso
                      X.509 Certificate: <copy and paste from the metadata file provided by Global Pass>
                      Login mode: checked "Use SAML as secondary authentication"
                      Remember user logins: checked

				ii.	Update files for handling multiple login option (Global Pass and UserName & Password)
                Run bash script
                cd /opt
                ./enhance-multiple-login.sh
                      The bash script contains the following
                          #Copy "loginpageoption.vm" to destination folder
                          cp /opt/loginpageoption.vm /opt/atlassian/confluence/confluence

                          #backup "seraph-config.xml"
                          cp /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml-orig

                          #update "seraph-config.xml".  This file must be updated first
                          cp /opt/seraph-config.xml /opt/atlassian/confluence/confluence/WEB-INF/classes/seraph-config.xml


##### f. Upgrade Confluence plugins to the supported versions. (3 min)
    Go to "Confluence administration"
    Click on "Manage add-ons"

        Disable the following plugins if you see they are still enabled.

              Confluence Integration for Hipchat (*** not compatible with 6.4.3)
            	     Installed version: 6.31.2    Available version: 7.8.29
            		   Version 7.8.29 • Confluence Server 5.7 - 6.3.4 • Released 2016-11-29

              IM Presence NG Plugin
                    Installed version: 2.8.3    Available version: 2.8.4
                    Version 3.0.0 • Confluence Server 6.1.0 - 6.10.02017-03-28
                    Released 2017-03-28 • No Vendor Support • Free • BSD

              SAML SingleSignOn for Confluence
                    Installed version: 0.14.7   Available version: 2.0.11
                    Version 2.3.3 • Confluence Server 5.10.0 - 6.10.0 • Released 2018-07-09

        Upgrade the following plugins

              Draw.io Confluence Plugin
              		  Installed version: 7.1.2    Available version: 8.0.5
              	    Version 8.0.5 • Confluence Server 5.10.0 - 6.10.0 • Released 2018-07-10

              Support Tools Plugin
              		  Installed version: 3.10.6   Available version: 4.0.2
              		  Version 4.0.2 • Confluence Server 5.9.14 - 6.5.3,
              		  Released 2017-12-14 • Supported By Atlassian • Free • BSD

              Atlassian Universal Plugin Manager Plugin
              		  Version: 2.21.5             Available version: 2.22.11
              		  Confluence Server 5.10.0 - 6.10.0
              		  Released 2018-06-20

##### g. Post-Upgrade Checklist and other integration test
        (https://confluence.atlassian.com/conf64/confluence-post-upgrade-checks-936511832.html)
        	a. Layout and Menu
            	Visit the Confluence dashboard and check that it is accessible and displays as expected. Test the different Internet browsers that you have in use in your environment. In addition, confirm that the layout appears as expected and that the menus are clickable and functioning.

        	b. Search
           		Try searching for content, for example pages, attachments or user names. Check that the expected results are returned.

        	c. Permissions
           		Confirm that you can visit a page that has view restrictions, but you have permission to view. Confirm that you can edit a page that has edit restrictions but you have permission to edit. Make sure that the permissions of child pages are functioning as well. Involve as many space administrators as possible to confirm they are working. Confirm that anonymous or forbidden users cannot access or modify restricted pages.

        	d. Attachments
          		Confirm that attachments are accessible and searchable.

		•	Run through checklist of test case

**Make go or no-go decision**
•	If no-go, do back-out
•	If go, continue below – can start Node 2 once go decision is made.


### 7. Upgrade Confluence – Node 2 (20 min)
​Copy upgraded Confluence v6.4.3 directories on Node 1 to Node 2
##### a. Stop Confluence on the first node.

##### b. Copy the installation directory and local home directory from the first node to the next node. (6 min)
			Create tar file
					cd /opt
					tar -czvf atlassian-6.4.3-node1.tar.gz atlassian		(4 min)

			Copy tar file to destination node (1 min)
					scp -i /home/ec2-user/cscdevcloudcustomerzero.pem /opt/atlassian-6.4.3-node1.tar.gz ec2-user@35.153.252.171:/tmp

			Putty to Node 2 and copy tar file to "/opt" folder (1 min)
					cd /opt
					mv /tmp/atlassian-6.4.3-node1.tar.gz .
					chown root:root atlassian-6.4.3-node1.tar.gz
					tar -xzvf atlassian-6.4.3-node1.tar.gz

			Change node name from node1 to node2 (< 1 min)
					vi /opt/atlassian/confluence/bin/setenv.sh
						change
							 from:	CATALINA_OPTS="-Dconfluence.cluster.node.name=node1 ${CATALINA_OPTS}"
							 to:		CATALINA_OPTS="-Dconfluence.cluster.node.name=node2 ${CATALINA_OPTS}"

			Confirm Node 2 Private IP address in the Confluence config file (< 1 min)
				vi /opt/atlassian/confluence-data/confluence.cfg.xml
             <property name="confluence.cluster.peers">10.0.0.197,10.0.0.245</property>

##### c. Start Confluence on second node, and confirm that you can log in and view pages on this node. (4 min)
			service confluence start

      Check Tomcat log file for any errors
          tail -f /opt/atlassian/confluence/logs/catalina.out

      Check Confluence log file for any errors
          tail -f /opt/atlassian/confluence-data/logs/atlassian-confluence.log

			Login to Confluence Dashboard and confirm you are login on node2.  This "node2" is displayed in the foot note like "Powered by Atlassian Confluence 6.4.3 (node2: xxxxxxxx)".  Or you check if you are on node2 by goto "Confluence administration" --> Clustering --> Confirm "node2" has circle green and with black bolded color text.

##### d. Post-Upgrade Checklist on Node 2 (10 min)
			(https://confluence.atlassian.com/conf64/confluence-post-upgrade-checks-936511832.html)
			> Layout and Menu
					Visit the Confluence dashboard and check that it is accessible and displays as expected. Test the different Internet browsers that you have in use in your environment. In addition, confirm that the layout appears as expected and that the menus are clickable and functioning.

			> Search
					Try searching for content, for example pages, attachments or user names. Check that the expected results are returned.

			> Permissions
					Confirm that you can visit a page that has view restrictions, but you have permission to view. Confirm that you can edit a page that has edit restrictions but you have permission to edit. Make sure that the permissions of child pages are functioning as well. Involve as many space administrators as possible to confirm they are working. Confirm that anonymous or forbidden users cannot access or modify restricted pages.

			> Attachments
					Confirm that attachments are accessible and searchable.

		•	Run through checklist

**Make go or no-go decision**
    •	If no-go, do back-out
		•	If go, continue below


### 8. Final testing (30min)

	Turn on Confluence on node 1 and node 2 and watch for any error in the log

	NOTE: Update this section. Most of the testing would have already occurred based on checklist. Review items below for checklist

		a.	Verify that any Atlassian application integrations are working properly. Examples include Confluence integrated with Jira.
		b.	Verify that any custom integrations are working properly. Examples include Confluence integrated with SAML Authentication.
		c.	Verify that any application's add-ons are working properly.
		d.	Verify that the Global Pass is working properly.
		e.	Perform a manual or automated smoke test to check the application's basic functionality and dominant use cases.


**Make go or no-go decision**
If no-go, do back-out
If go, communicate to the users and update Announcement banner and celebrate!!


### 9.	Back-out Plan (30 min)
	AWS
		1.	Database
				a.	Restore the database snapshot of MySql version 5.6.27 from step 2.b above.
				b.	Change the database connection string to use the database instance.

		2.	EC2 (Linux server)
				a.	Restore the snapshot of volume EBS “xvda1” and “xvdb” on node 1
				b.	Restore the snapshot of volume EBS “xvda1” and “xvdb” on node 2

		3.	EFS
				a.	Unmount the current EFS (Confluence-efs) from root folder “/efs”
				b.	Mount the backup EFS (Confluence-efs-backup) to the root folder “/efs”

	Global Pass
		1.	Global Pass
				a.	Contact Global Pass team to change the ACS URL and Entity ID back to previous setup

		2.	Test and confirm everything working fine.


### 10.	Coordination Needed
	Global Pass Team Needed

	Our Team
		•	Tien, Jay on-board 3pm Pacific to 9:30pm Pacific Aug 03
		•	Ravi on-board for what he can attend, but on-call

	Communication with users
		•	Upgrade starts and systems are inaccessible (3:00pm Pacific)
