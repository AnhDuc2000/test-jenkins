# Implementation Plan for upgrading Confluence v6.4.3 and MySql Db v5.6.39

This implementation plan is for upgrading Confluence v5.9.5 to v6.4.3 and MySql Db v5.6.27 to v5.6.39 on production.  Plus, Global Pass will be configured the new integrated SAML Authentication within Confluence.

| Task Name                                                    | Duration (minutes) | Start (pm) | End (pm) | Remark                        | Downtime Notes                                         |
| ------------------------------------------------------------ | ------------------ | ---------- | -------- | ----------------------------- | ------------------------------------------------------ |
| [AWS Production Information](#aws-production-information)                                   | 0                  |            |          |                               |                                                        |
| [Pre-upgrade](#pre-upgrade)                                  | 0                  |            |          |                               |                                                        |
| -----	1. Perform the health checks (this can be done in advance before starting MTP) (1 min) | 1                  |            |          |                               |                                                        |
| -----	2. Create a new parameter group (done in advance) (5 min) | 5                  |            |          |                               |                                                        |
| -----	3. Perform Confluence Update Check (1 min)          | 1                  |            |          |                               |                                                        |
| [1. Backup atlassian folder (Continue without waiting for this complete) (3 min)](#1-backup-atlassian-folder-continue-without-waiting-for-this-complete-3-min) | 3                  | 3:00       | 3:03     | MTP Start at 3pm PST          | Note: systems are still up                             |
| [2. Perform screen captures and DB queries (5 min)](#2-perform-screen-captures-and-db-queries-10-min)            | 10                 | 3:03       | 3:13     | a & b in parallel             |                                                        |
| -----	1. Capture screen for "Confluence Usage" (1 min)    | 1                  |            |          |                               |                                                        |
| -----	2. Run DB queries (10 min)                          | 5                  |            |          |                               |                                                        |
| [3. Back up (40 min)](#3-back-up-40-min)                                          | 40                 | 3:13       | 3:53     | 3 & 4 can be done in parallel | Start of downtime 3:13pm PST                           |
| -----	1. Stop the cluster (1 min)                         | 1                  |            |          |                               |                                                        |
| -----	2. Back up rsynch (40 min)                          | 40                 |            |          |                               |                                                        |
| -----	3. perform snapshot of xvda and xvdb (4 min, in parallel with efs) | 4                  |            |          |                               |                                                        |
| [4. Perform MySQL database upgrade (50 min)](#4-perform-mysql-database-upgrade-50-min)                   | 50                 | 3:13       | 4:03     | 3 & 4 can be done in parallel |                                                        |
| -----	1. Perform snapshot of DB (5 min)                   | 5                  |            |          |                               |                                                        |
| -----	2. Change DB version with new parameter group "confluence-mysql" (33) | 33                 |            |          |                               |                                                        |
| -----	3. Run DB queries and compare with pre db upgrade (5 min) | 5                  |            |          |                               |                                                        |
| -----	4. Start Confluence on node 1 (5 min)               | 5                  |            |          |                               |                                                        |
| [5. Clear old add-on cache, index, and temp files (3 min)](#5-clear-old-add-on-cache-index-and-temp-files-4-min)     | 3                  | 4:03       | 4:07     |                               |                                                        |
| -----	1. Shutdown Confluence on Node 1 (1 min)            | 1                  |            |          |                               |                                                        |
| -----	2. Deleting the content of the indexes, old add-on cache and temp files (2 min) | 2                  |            |          |                               |                                                        |
| [6. Upgrade Confluence – Node 1 (1 hr + 15 min)](#6-upgrade-confluence--node-1-1-hr--15-min)               | 75                 | 4:07       | 5:22     |                               | About 5:15pm Node 1 will be up with GP, but reindexing |
| -----	1. Perform upgrade on 1st node (10 min)             | 10                 |            |          |                               |                                                        |
| -----	2. For MySQL database, replace the latest jdbc driver and backup older one. (1 min) | 1                  |            |          |                               |                                                        |
| -----	3. Reapply any customizations, like JVM properties, from the old version to the new one. (3 min) | 3                  |            |          |                               |                                                        |
| -----	4. Start Confluence. During this step, your database will be upgraded. (28 min) | 28                 |            |          |                               |                                                        |
| -----	5. Global Pass – upgrade SAML Configuration (15 minutes) | 15                 |            |          |                               |                                                        |
| -----	6. Upgrade Confluence plugins to the supported versions. (3 min) | 3                  |            |          |                               |                                                        |
| -----	7. Post-Upgrade Checklist and other integration test (15 min) | 15                 |            |          |                               |                                                        |
| [7. Upgrade Confluence – Node 2 (20 min)](#7-upgrade-confluence--node-2-20-min)                      | 20                 | 5:22       | 5:42     |                               | Node 2 is up 5:42pm PST                                |
| -----	1. Stop Confluence on the first node                | 1                  |            |          |                               |                                                        |
| -----	2. Copy the installation directory and local home directory from the first node to the next node. (10 min) | 10                 |            |          |                               |                                                        |
| -----	3. Start Confluence on second node, and confirm that you can log in and view pages on this node |                    |            |          |                               |                                                        |
| -----	4. Post-Upgrade Checklist on Node 2 (10 min)        | 15                 |            |          |                               |                                                        |
| [8. Final testing (30 min)](#8-final-testing-30min)                                    | 30                 | 5:42       | 6:12     |                               | Complete of MTP 6:12pm PST                             |
| [9. Back-out Plan (30 min)](#9-back-out-plan-30-min)                                    | 30                 |            |          |                               |                                                        |
| [10. Coordination Needed](#10coordination-needed)                                      |                    |            |          |                               |                                                        |


## AWS Production Information
VPC:	vpc-5b49163f - csc-devcloud-os-customer-zero
Zone:	us-east-1a

| Type |             Name              |     Elastic IP | Public IP      | Private IP | Public DNS (IPv4)                          |
| ---- |:-----------------------------:| --------------:| -------------- | ---------- | ------------------------------------------ |
| ec2  |    confluence-node01-prod     |   52.73.177.83 | 52.73.177.83   | 10.0.0.197 | ec2-52-73-177-83.compute-1.amazonaws.com   |
| ec2  |    confluence-node02-prod     | 35.153.252.171 | 35.153.252.171 | 10.0.0.245 | ec2-35-153-252-171.compute-1.amazonaws.com |
| ec2  | confluence-node03-prod-backup |                | 54.210.129.196 | 10.0.0.90  | ec2-54-210-129-196.compute-1.amazonaws.com |
| efs  |        confluence-efs         |                |                | 10.0.0.72  |                                            |
| rds  |          cz-mysqldb           |                |                |            |                                            |

## Pre-upgrade

All this work can be done in advance of the MTP downtime

**Disable the root crontab until the manual rsync completed by comment out the line below**
	```
	0 10,22 * * * /usr/local/bin/confluence-rsync-efs.sh
	```

**Node 1**

- assumes the following files are available under "/opt". These files were copied from <https://github.dxc.com/Platform-DXC/confluence/blob/master/code/upgrade/confluence-6.4.3>
```
	atlassian-confluence-6.4.3-x64.bin
	mysql-connector-java-5.1.46-bin.jar
	backup-atlassian-5.9.5.sh
	cleanup-file.sh
	enhance-multiple-login.sh
	update-mysql-driver.sh
	loginpageoption.vm
	seraph-config.xml
```
- assumes the following file is available under "/home/ec2-user"
```
	cscdevcloudcustomerzero.pem
```
**Putty**
Need to open using Putty
* two terminals for node 1 (52.73.177.83)
* two terminals for node 2 (35.153.252.171)
* one terminal connecting to "confluence-node03-prod-backup--ec2-user@54.210.129.196" to do rsync

**AWS**
Need to log in AWS prod on RDS, EC2
* Ensure you are connected to Production AWS Management Console
  * [Production AWS Management Console](https://035015258033.signin.aws.amazon.com/console)
* [AWS DB Instances](https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstances)
* [AWS EC2 Instances](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:search=confluence;sort=instanceId)

**Jumpserver Remote Desktop Connection** 
Need to open one Remote Desktop Connection to connect to the Jumpserver to get access to the Database. Use the below information
- Public DNS: ec2-54-89-151-235.compute-1.amazonaws.com
- User name: Administrator
- Password: <see any team member>

## Complete the pre-upgrade checks
1. Perform the health checks (this can be done in advance before starting MTP) (0 min)

- Go to [Confluence administration > General Configuration > Atlassian Support Tools](https://confluence.csc.com/plugins/servlet/stp/view/)
	Click on "Instance Health" tab, you will see the Problems Detected 
	- Database 
		- InnoDB Log File Size
			- Result: Your innodb_log_file_size of 134,217,728 is too small. You should increase innodb_log_file_size to 256M.
			- Resolve: On AWS, create a new parameter group and set "innodb_log_file_size" to 512M
                     [MySQLSyntaxErrorException: Row size too large](https://confluence.atlassian.com/confkb/mysqlsyntaxerrorexception-row-size-too-large-658735905.html?utm_campaign=stp-health-checks-beta&utm_medium=stp-jdk-health-check&utm_source=stp)

		- max_allowed_packet
         	- Result: Your packet size of 4,194,304 is too small. You should increase max_allowed_packets to 34M.
			- Resolve: On AWS, create a new parameter group and set "max_allowed_packet" to 512M

2. Create a new parameter group (done in advance) (5 min)  

**NOTE**: the following steps to create a new parameter group will be fully completed during the database upgrade later.  

- On AWS, on left-navigation, go to RDS > [Parameter groups]([https://console.aws.amazon.com/rds/home?region=us-east-1#parameter-groups:id=) and click on "Create parameter group" button and fill in the following information on the "Create parameter group" screen.

	- Parameter group family = "mysql5.6"
	- Group name = "confluence-mysql"
	- Description = "Customize parameter group for MySQL to use by Confluence"

Click on "Create"
- Search for "confluence-mysql" and make the following changes
  - Change parameter value of "innodb_log_file_size" to 536870912	(512M)
  	 Change parameter value of "max_allowed_packet" to 536870912 	(512M )


3. Perform Confluence Update Check (this can be done in advance before starting MTP) (0 min)
    - Go to [Confluence administration > Manage add-ons > Confluence update check](https://confluence.csc.com/plugins/servlet/upm/check?source=manage).  For "Check compatibility for update to", select "6.4.3" and click on "Check" 
      - Comala Publishing and Draw.io will indicate compatable 
      - Find “SAML SingleSignOn for Confluence” and click on "Disable" button.
## 1. Backup atlassian folder (Continue without waiting for this complete) (3 min) 
Need to copy "/opt/atlassian" folder to folder "/opt/bak-confluence-5.9.5", because some information from previous version is still needed after upgraded.  

Putty to Confluence node 1 “52.73.177.83” (10.0.0.197)
```
sudo su
cd /opt
./backup-atlassian-5.9.5.sh 
```
For bash script of this file, click [backup-atlassian-5.9.5.sh](https://github.dxc.com/Platform-DXC/confluence/blob/master/code/upgrade/confluence-6.4.3/backup-atlassian-5.9.5.sh)

## 2. Perform screen captures and DB queries (10 min)

**NOTE:** we'll have to work together to create github pull requests and get them approved so we get github accurate right away.

1. Capture screen for "Confluence Usage" (3 min)  
  - Go to [View System Information](https://confluence.csc.com/admin/systeminfo.action)
  - Right mouse click. View as source and save as htm file for future comparison.
  - Store the screenshot at <https://github.dxc.com/Platform-DXC/confluence/blob/master/docs/MTP/Confluence-6.4.3-Upgrade/>
2. Run DB queries (done in parallel with step 1)(10 min)
  - Go to Windows Jump Server "ec2-54-89-151-235.compute-1.amazonaws.com"
        Run the queries which are located under the folder "C:\Users\Administrator\Documents\sql\confluence" or stored in GitHub at <https://github.dxc.com/Platform-DXC/confluence/blob/master/code/upgrade/Confluence-6.4.3-Upgrade/> 

        - 1-List of users who assigned to spaces and groups  (1 mins)  
        - 2-List Number of pages in a space ( < 1 min)  
        - 3-List number of attachment size in a spaces ( < 1 min)  
        - 4-List all tables with row count ( < 1 mins)
  - Save the result of each query at <https://github.dxc.com/Platform-DXC/confluence/blob/master/docs/MTP/Confluence-6.4.3-Upgrade/> or in the following folders

    - C:\Users\Administrator\Documents\sql\confluence\report\1-Before-DB-Upgrade
    - C:\Users\Administrator\Documents\sql\confluence\report\2-After-DB-Upgrade
    - C:\Users\Administrator\Documents\sql\confluence\report\3-After-Confluence-Upgrade
  - Atom software, pre-installed on the jumper windows server, will be used later to compare before and after cvs files.

## 3. Back up (40 min)

1. Stop the cluster (1 min)
	- Putty to Confluence node 1 “52.73.177.83” (10.0.0.197)
	```
		sudo su
		service confluence stop
	```
	- Putty to Confluence node 2 “35.153.252.171” (10.0.0.245)
    ```
		sudo su
		service confluence stop
    ```

2. Run rsynch to pull in recent changes since last run (40 min)
  - Putty to confluence-node03-prod-backup--ec2-user@54.210.129.196 (54.210.129.196)
  ```
  	sudo su
  	cd /usr/local/bin
  	./confluence-rsync-efs.sh
  ```
  - For copy of bash script, click [confluence-rsync-efs.sh](https://github.dxc.com/Platform-DXC/confluence/blob/master/code/upgrade/confluence-6.4.3/confluence-rsync-efs.sh)

3. Perform snapshot of xvda and xvdb (4 min, in parallel with efs)
	- Node1:
	  - Take snapshot of confluence-node01-prod root  -- confluence-node01-prod-new -- vol-bdd98219 -- 80 GiB
			<https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-bdd98219;sort=desc:createTime>
		- Action --> Create Snapshot
		  - Description:  confluence-node01-prod-ebs-volume-sda1-root
		  - Tag:
				 Key: 	Name;
				 Value: 	confluence-node01-prod-ebs-volume-sda1-root-mtp
	
	  - Take snapshot of confluence-node01-prod opt  -- confluence-node01-prod-new -- vol-74da81d0 -- 100 GiB
			<https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-74da81d0;sort=desc:createTime>
		- Action --> Create Snapshot
		  - Description:  confluence-node01-prod-ebs-volume-sdb-opt
		  - Tag:
				 Key: 	Name;
				 Value: 	confluence-node01-prod-ebs-volume-sdb-opt-mtp

	- Node2:
	  - Take snapshot of confluence-node02-prod root  -- confluence-node02-prod-new -- vol-0de1a38ce41034c1b -- 80 GiB
			<https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-0de1a38ce41034c1b;sort=desc:createTime>
		- Action --> Create Snapshot
		  - Description:  confluence-node02-prod-ebs-volume-sda1-root
		  - Tag:
				 Key: 	Name;
				 Value: 	confluence-node02-prod-ebs-volume-sda1-root-mtp
	
	  - Take snapshot of confluence-node02-prod opt  -- confluence-node02-prod-ebs-xvdb-opt -- vol-0eff49e243c56dbb8 -- 100 GiB
			<https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Volumes:search=vol-0eff49e243c56dbb8;sort=desc:createTime>
		- Action --> Create Snapshot
		  - Description:  confluence-node02-prod-ebs-volume-sdb-opt
		  - Tag:
				 Key: 	Name;
				 Value: 	confluence-node02-prod-ebs-volume-sdb-opt-mtp


## 4. Perform MySQL database upgrade (50 min)
**Note**: Make sure the database is not in "backing up" status. Within RDS review the status prior to backing up. Also, this step is done in parallel with the previous: **Step 3: Backup** 
1. Take a snapshot of DB (5 min)  
  - Go to [DB Instances > cz-mysqldb](https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstance:id=cz-mysqldb)

  - Go backwards to DB Instances and select **cz-mysqldb**

  - Click on "Instance actions" > "Take snapshot" 

  - Enter "cz-mysqldb-v5-6-27-d2018-08-03-mtp" for "Snapshot name"  

    Note: you might see the message "backup-up" under RDS > Instances

2. Change DB version with new parameter group "confluence-mysql" (30 min upgrade + 3 min reboot to apply update db parameter option)
    - Go to RDS Instances: [Instances](https://console.aws.amazon.com/rds/home?region=us-east-1#dbinstances:)
      - Find "cz-mysqldb" and click on it
      - Scroll down to the middle of the page and click on "Modify" button
        - Change "DB engine version"
      		  - From: mysql 5.6.27
      		  - To:   mysql 5.6.39 (default)

        - Change "DB parameter group"
      		  - From:  default.mysql5.6
      		  - To:	  confluence-mysql

      		- Click on "Continue" button

      		- Select "Apply immediately"  
    	  - Summary of Modifications
      			- You are about to submit the following modifications. Only values that will change are displayed. Carefully verify your changes and click Modify DB Instance.

				| Attribute          | Current Value         | New Value             |
				| ------------------ | --------------------- | --------------------- |
	  		| DB engine version  | 5.6.27 (MySQL 5.6.27) | 5.6.39 (mysql 5.6.39) |
	  		| DB parameter group | default.mysql5.6	     | confluence-mysql      |

	
		- Click on "Modify DB Instance", you will see the status of these below
		
			- RDS > Instances -- you will see status = "upgrading" (22 min)
				- RDS > Instances -- you will see status = "modifying" (1 min)
				- RDS > Snapshots -- you will see status = "creating"  (navigate to the last page to see this)
		
    	  - When you see in the parameter group with the status of "confluence-mysql (pending-reboot)", then perform in below to reboot.
    	    - Select "cz-mysqldb"
    	    - Click on "Instance actions" --> "Reboot" --> "Reboot" button
    	      - Status: rebooting 
    	      - After the status of db is "Available", in the "parameter group" it should said "cz-mysqldb (in-sync)"


3. Run DB queries and compare with pre db upgrade (5 min)
  - Run the DB queries at step 2-b and save the results as this sub-folder "2-After-DB-Upgrade"

   - Compare these results with the previous ran db queries at this sub-folder "1-Before-DB-Upgrade" from step 2-b using Atom software        

4. Start Confluence on Node 1 (5 min)
    - Putty to Node 1 and start Confluence (3 min)
    ```
        service confluence start
    ```

    - Make sure no major errors in the Atlassian log.  You might see the Hipchat error.

      - On Confluence, check "Instance Health" (1 min)
        - Go to [Confluence administrator](https://confluence.csc.com/admin/viewgeneralconfig.action)
        - Click on [Support Tools](https://confluence.csc.com/plugins/servlet/stp/view/)
          - Click on "Instance health" tab and make sure very thing is passed checks especially database.

      - On Confluence, go to [Space Directory](https://confluence.csc.com/spacedirectory/view.action) and try to navigate to any spaces and confirm it is working fine. (1 min)
        - Click on Confluence Home Page (Confluence Dashboard)
        - Click on "Spaces" --> ["Space Directory"](https://confluence.csc.com/spacedirectory/view.action)
               
    		  
**Go/No-go Decision on MySQL Upgrade**
If not satisfied with MySQL upgrade

- revert back to original snapshot and continue below (10m)
- have to change the Confluence configuration file "confluence.cfg.xml" to point to the original instance db (See **Back-out Plan – Database**).

Otherwise, continue below

## 5. Clear old add-on cache, index, and temp files (4 min)
1. Shutdown Confluence on Node 1 (1 min)
   ```
        service confluence stop
	```

2. Deleting the content of the indexes, old add-on cache and temp files (2 min)
    ```
        cd /opt/
        ./cleanup-file.sh
    ```
	- For bash script of this file, click [cleanup-file.sh](https://github.dxc.com/Platform-DXC/confluence/blob/master/code/upgrade/confluence-6.4.3/cleanup-file.sh)


## 6. Upgrade Confluence – Node 1 (1 hr + 15 min)
1. Perform upgrade on 1st node (10 min)
  - Make sure you don't have any opened sessions currently under folder "/opt/*".
  - Make sure there is not any backup files in the "/opt/atlassian/confluence-data/temp".  Otherwise it will take a lot of time for backing up the confluence folders during upgrade process

  - Perform upgrade on 1st Node.  Putty to Confluence node 1
```
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
                   [http://docs.atlassian.com/confluence/docs-64/Production+Backup+Strategy](http://docs.atlassian.com/confluence/docs-64/Production+Backup+Strategy)
   
                   Check plugin compatibility
                   Check that your non-bundled plugins are compatible with Confluence 6.4.3.
   
                   For more information see our documentation at the following URL:
                   [http://docs.atlassian.com/confluence/docs-64/Installing+and+Configuring+Plugins+using+the+Universal+Plugin+Manager](http://docs.atlassian.com/confluence/docs-64/Installing+and+Configuring+Plugins+using+the+Universal+Plugin+Manager)
  
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
                    [http://docs.atlassian.com/confluence/docs-64/Upgrading+Confluence#UpgradingConfluence-custommodifications](http://docs.atlassian.com/confluence/docs-64/Upgrading+Confluence#UpgradingConfluence-custommodifications)
                    Finishing installation ...
```

2. For MySQL database, replace the latest jdbc driver and backup older one. (1 min)
   ```    
    cd /opt
    ./update-mysql-driver.sh       
	```
	- For bash script of this file, click [update-mysql-driver.sh](https://github.dxc.com/Platform-DXC/confluence/blob/master/code/upgrade/confluence-6.4.3/update-mysql-driver.sh)


3. Reapply any customizations, like JVM properties, from the old version to the new one. (3 min)

  **Tien: recommend create the *.sh files in advance, along with the destination file. The source file, such as, setenv.sh, would be copied to bak-setenv.sh prior to running the script to replace the file.**

  - Modify Tomcat files
  ```
   		vi /opt/atlassian/confluence/bin/setenv.sh
  ```
  - Change:
    - From:	CATALINA_OPTS="-Xms1024m -Xmx1024m -XX:+UseG1GC ${CATALINA_OPTS}"
    	 To:	CATALINA_OPTS="-Xms1024m -Xmx4096m -XX:+UseG1GC ${CATALINA_OPTS}"

   - Add:
     - CATALINA_OPTS="-Dconfluence.cluster.node.name=node1 ${CATALINA_OPTS}"
     - CATALINA_OPTS="-Dconfluence.upgrade.recovery.file.enabled=false ${CATALINA_OPTS}"

  - Modify Confluence file
  ```
  	vi /opt/atlassian/confluence/conf/server.xml
  ```
   - Change:
  ```
  	<Connector port="8090" connectionTimeout="60000" redirectPort="8443"
  		proxyName="confluence.csc.com"
  		proxyPort="443"
  		scheme="https"
  		secure="true"
  		maxThreads="48" minSpareThreads="10"
  		enableLookups="false" acceptCount="10" debug="0" URIEncoding="UTF-8"
  		protocol="org.apache.coyote.http11.Http11NioProtocol" />
  ```
   - Increase the maximum backup log file to 25 so we can have more records of history activities about Confluence 6.4.3 upgrade.
  ``` 
  	vi /opt/atlassian/confluence/confluence/WEB-INF/classes/log4j.properties 
  ```
   - Change:
     - From: log4j.appender.confluencelog.MaxBackupIndex=5
     - To: log4j.appender.confluencelog.MaxBackupIndex=25

4. Start Confluence. During this step, your database will be upgraded. (13 min finished task upgrade + 15 min to check for any errors in the logs and db query results)

   - i. Start Confluence and check for any errors in the logs (15 min)
      - Run this command as root
      	```
           service confluence start
      	```
      - Check Tomcat log file for any errors
   		```
        	tail -f /opt/atlassian/confluence/logs/catalina.out
        ```
      
      		Check Confluence log file for any errors
      	```
      		tail -f /opt/atlassian/confluence-data/logs/atlassian-confluence.log
      	```
        
      - After you have completed an upgrade, you should see the following message in the atlassian-confluence.log file:
   	```
        2010-03-08 08:03:58,899 INFO [main] [atlassian.confluence.upgrade.AbstractUpgradeManager]
        atlassian-confluence.log:2018-07-22 21:18:11,221 INFO [localhost-startStop-1] [atlassian.confluence.upgrade.AbstractUpgradeManager] initialUpgradeFinished Upgrade initial stage completed successfully
            
   		atlassian-confluence.log:2018-07-22 21:18:37,303 INFO [localhost-startStop-1] [atlassian.confluence.upgrade.AbstractUpgradeManager] entireUpgradeFinished Upgrade completed successfully
   	```
      - If you do not see the line in your log similar to the one above, this means that your upgrade may not have completed successfully. Please check our Upgrade Troubleshooting <https://confluence.atlassian.com/confkb/upgrade-troubleshooting-180847191.html> documentation to check for a suitable recommendation or fix.  In this case, we need to make the decision to roll back or continue.

      - **Note**: During the upgrade process, you might see the warning message "java.lang.OutOfMemoryError: Java heap space".  Do not terminate the process and wait for its process to finished, This might take a few minutes.  This error does not occur if you have below setup in "setenv.sh"
   	```
        CATALINA_OPTS="-Dconfluence.upgrade.recovery.file.enabled=false ${CATALINA_OPTS}"
   	```

      - If you see this error in Confluence UI "Confluence cluster node will not start up because the build number in the database [6212] doesn't match either the application build number [7402] or the home directory build number [7402].", it means the upgrade is not successful.  See here for the fix <https://confluence.atlassian.com/confkb/confluence-will-not-start-up-because-the-build-number-in-the-home-directory-doesn-t-match-the-build-number-in-the-database-after-upgrade-376834096.html>.  In this case, we need to make the decision to roll back or continue.

    - ii. Check MySQL DB using this "select * from CONFVERSION;" to confirm all the previous versions upgraded successfully like in below (< 1 min)
    ```
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
    ```

    - iii. Check "confluence.cfg.xml" and confirm the build number 7402 is the same as on the database (< 1 min)
   ```
       	view /opt/atlassian/confluence-data/confluence.cfg.xml
        	<buildNumber>7402</buildNumber>
   ```

    - iv. Run the DB queries at step 2-b and perform screen captures
		- Run the DB queries at step 2-b
		- Save the result at this sub-folder "3-After-Confluence-Upgrade"      
		- Compare these results with the previous ran db queries at this sub-folder "2-After-DB-Upgrade"    
		- Perform screen captures

    - v. Check Clustering (< 1 min)
      - Go to [Confluence administrator](https://confluence.csc.com/admin/viewgeneralconfig.action)
      	 Click on [Clustering](https://confluence.csc.com/plugins/servlet/cluster-monitoring) and 		confirm Node name "node1" is currently running

    - vi. Check "Instance Health" (< 2 min)
      - Go to [Confluence administrator](https://confluence.csc.com/admin/viewgeneralconfig.action)
      - Click on [Support Tools](https://confluence.csc.com/plugins/servlet/stp/view/)
      - Click on "Instance health" tab and make sure very thing is passed checks.

        - Except "Administration" is failed because we use an user "Administrator" instead of "admin" and both Internal directory and Jira directory have same account of "Administrator".
   	  - Result: Confluence has an enabled internal user directory, however its administrator account does not exist or is disabled
          - Resolution: For this check to pass Confluence will need to be using an SSO solution or:
            - 1. An Internal User Directory that is active.
            - 2. A System Admin User in that Internal Directory.
                  <https://confluence.atlassian.com/confkb/health-check-internal-administrator-user-829068290.html>
                  <https://www.redradishtech.com/display/KB/Reordering+User+Directories+in+JIRA+and+Confluence>

   - vii. Check System Information
      - Go to [Confluence administrator](https://confluence.csc.com/admin/viewgeneralconfig.action)
      - Click on "System Information"
        - Confluence Version: 6.4.3
        - Build Number: 7402
        - Database version: 5.6.39-log
        - Database Driver Version: mysql-connector-java-5.1.46

    - viii. On Confluence, go to "Space Directory" and try to navigate to any spaces and confirm it is working fine (< 3 min)
   			   Click on Confluence Home Page (Confluence Dashboard)
   			   Click on "Spaces" --> ["Space directory"]([https://confluence.csc.com/spacedirectory/view.action)

    - ix. Check and confirm re-Index automatically started right after 1 or 2 min from this message "init Confluence is ready to serve" on Node 1 (40 min)
      - Go to [Confluence administrator](https://confluence.csc.com/admin/viewgeneralconfig.action)
      - Select "Content Indexing"
      - Click on "Search Indexes" and confirm the index is running
            <https://Confluence.csc.com/secure/admin/IndexAdmin.jspa>

5. Global Pass – upgrade SAML Configuration (15 minutes)
  - Configure SAML Configuration with Global Pass metadata (ACS url, Entity ID, certificate)
    - Go to [Confluence administrator](https://confluence.csc.com/admin/viewgeneralconfig.action)
    - Click on "SAML Authentication" on the left menu
      - Authentication method:  checked "SAML single sign-on"
      - Single sign-on issuer:  urn:federation:csc
      - Identity provider single sign-on URL: <https://gpl.amer.csc.com/affwebservices/public/saml2sso>
      - X.509 Certificate: <copy and paste from the metadata file provided by Global Pass>
      - Login mode: checked "Use SAML as secondary authentication"
      - Remember user logins: checked

  - Update files for handling multiple login option (Global Pass and UserName & Password). For bash script of this file, click [enhance-multiple-login.sh](https://github.dxc.com/Platform-DXC/confluence/blob/master/code/upgrade/confluence-6.4.3/enhance-multiple-login.sh)
  ```
      cd /opt
      ./enhance-multiple-login.sh
  ```

  - Update the keep alive in AWS
    - Open AWS Console
    		Go to ELB Settings
    		Find the Confluence Prod ELB element
    		Open health checks
    		Change the health check from /plugins/servlet/samlsso to /status

6. Upgrade Confluence plugins to the supported versions. (3 min, assuming parallel team effort)
  - Go to "Confluence administration"
   - Click on "Manage add-ons"
     - Disable the following plugins if you see they are still enabled.
       - Confluence Integration for Hipchat (*** not compatible with 6.4.3)
         - Installed version: 6.31.2    Available version: 7.8.29
         - Version 7.8.29 • Confluence Server 5.7 - 6.3.4 • Released 2016-11-29

       - IM Presence NG Plugin
         - Installed version: 2.8.3    Available version: 2.8.4
         - Version 3.0.0 • Confluence Server 6.1.0 - 6.10.02017-03-28
         - Released 2017-03-28 • No Vendor Support • Free • BSD

       - SAML SingleSignOn for Confluence
         - Installed version: 0.14.7   Available version: 2.0.11
         - Version 2.3.3 • Confluence Server 5.10.0 - 6.10.0 • Released 2018-07-09

     - Upgrade the following plugins
         - Draw.io Confluence Plugin
         - Installed version: 7.1.2    Available version: 8.0.5
         - Version 8.0.5 • Confluence Server 5.10.0 - 6.10.0 • Released 2018-07-10

     - Support Tools Plugin
         - Installed version: 3.10.6   Available version: 4.0.2
         - Version 4.0.2 • Confluence Server 5.9.14 - 6.5.3,
         - Released 2017-12-14 • Supported By Atlassian • Free • BSD

     - Atlassian Universal Plugin Manager Plugin
         - Version: 2.21.5             Available version: 2.22.11
         - Confluence Server 5.10.0 - 6.10.0
         - Released 2018-06-20

7. Post-Upgrade Checklist and other integration test (15 min)

    - Some of the following test cases came from a recommendation from Atlassian
      - <https://confluence.atlassian.com/conf64/confluence-post-upgrade-checks-936511832.html> 

    - Run through test cases. Go [here](../../../tests/README.md).

8. **Make go or no-go decision**

    If no-go, do back-out. Go to **9. Backout**.

    If go, continue below – can start Node 2 once go decision is made.


## 7. Upgrade Confluence – Node 2 (20 min)
Copy upgraded Confluence v6.4.3 directories on Node 1 to Node 2

**NOTE: Don't want to do this work until Node 1 indexing has completed.** **Might have wait 10-15 min.**

1. Stop Confluence on the first node.

2. Copy the installation directory and local home directory from the first node to the next node. (10 min)
  - On Node 1 as root user, create a tar file and copy it to destination node 2 (1 min)
  ```	
  	cd /opt
  	./tar-atlassian-6.4.3-node1-send-to-node2.sh  	
  ```
   - Putty to Node 2 and copy tar file from "/tmp" folder to "/opt" folder 
  ```
		cd /opt
		./copy-tar-file-from-tmp-2-opt-folder.sh 
  ```
  - Change node name from node1 to node2
  ```
  	vi /opt/atlassian/confluence/bin/setenv.sh
  ```
  - Change
    - From:	CATALINA_OPTS="-Dconfluence.cluster.node.name=node1 ${CATALINA_OPTS}"
    	 To:		CATALINA_OPTS="-Dconfluence.cluster.node.name=node2 ${CATALINA_OPTS}"

  - Confirm Node 2 Private IP address in the Confluence config file 
  ```
  	vi /opt/atlassian/confluence-data/confluence.cfg.xml
  	<property name="confluence.cluster.peers">10.0.0.197,10.0.0.245</property>
  ```

3. Start Confluence on second node, and confirm that you can log in and view pages on this node. (6 min)
  ```
  	service confluence start
  ```
  Check Tomcat log file for any errors
  ```
		tail -f /opt/atlassian/confluence/logs/catalina.out
  ```
  Check Confluence log file for any errors
  ```
		tail -f /opt/atlassian/confluence-data/logs/atlassian-confluence.log
  ```
  Login to Confluence Dashboard and confirm you are login on node2.  This "node2" is displayed in the foot note like "Powered by Atlassian Confluence 6.4.3 (node2: xxxxxxxx)".  Or you can check if you are on node2 by goto "Confluence administration" --> Clustering --> Confirm "node2" has circle green and with black bolded color text.

4. Post-Upgrade Checklist on Node 2 (10 min)

     - Some of the following test cases came from a recommendation from Atlassian
       - <https://confluence.atlassian.com/conf64/confluence-post-upgrade-checks-936511832.html> 

     - Run through 50% of test cases, randomly. Go [here](../../../tests/README.md).

5. **Make go or no-go decision**

     If no-go, do back-out. Go to **9. Backout**.

     If go, continue below



## 8. Final testing (30min)
Turn on Confluence on node 1 and node 2 and watch for any error in the log.
	
NOTE: Most of the testing would have already occurred based on checklist. Review items below for checklist  
  -	a. Verify that any Atlassian application integrations are working properly. Examples include Confluence - integrated with Jira.

  - b. Verify that any custom integrations are working properly. Examples include Confluence integrated with SAML Authentication.

  - c. Verify that any application's add-ons are working properly.

  - d. Verify that the Global Pass is working properly.

  - e. Perform a manual or automated smoke test to check the application's basic functionality and dominant use cases.

**Make go or no-go decision**
If no-go, do back-out. See **9. Back-out Plan**
If go, communicate to the users and update Announcement banner and reenable the root crontab entry that runs confluence-rsync-efs.sh.

## 9. Back-out Plan (30 min)
1. AWS
  1. Database

     a. Restore the database snapshot of MySql version 5.6.27 from step 2.b above.

     b. Change the database connection string to use the database instance.

  2. EC2 (Linux server)
     a.	Restore the snapshot of volume EBS “xvda1” and “xvdb” on node 1
     b.	Restore the snapshot of volume EBS “xvda1” and “xvdb” on node 2

  3. EFS

     a. Unmount the current EFS (Confluence-efs) from root folder “/efs”
     b. Mount the backup EFS (Confluence-efs-backup) to the root folder “/efs”
     c. Re-enable the root crontab entry that runs confluence-rsync-efs.sh.

2. Global Pass
  1. Global Pass

     a.	Revert to previous setup using SAML Plugin

     	Contact Global Pass team to change the ACS URL and Entity ID back to previous setup, if issue 	

  2. Test and confirm everything is working fine.    

## 10. Coordination Needed

**NOTE:** Should setup an email invite with information on when folks would be on call

1. Global Pass Team (Radjika) Needed on call from about 5pm - 7pm PST
2. Our Team
  - Tien, Jay on-board 3pm Pacific to 7pm Pacific Aug 03
  - Adam, unavailable most of the time and can join when free
  - Linda, will checkin, periodically
  - Ravi on-board for what he can attend, but on-call
3. Communication with users
  - Upgrade starts and systems are inaccessible (3pm Pacific)