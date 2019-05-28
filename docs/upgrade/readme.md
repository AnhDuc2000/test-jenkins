# Confluence Upgrade Process

This document outlines our current Confluence upgrade process.  It presents a repeatable process that we intend to continue to automate and improve over time, including leveraging more CI/CD pipeline type practices.

Where there are version-specific, they will be called out in a specific sub-document.

## Pre-work
* Install [jq](https://stedolan.github.io/jq/) if you don't have one.  To install jq, use this command ``` yum install jq ```
* Install [Dos2Unix](http://dos2unix.sourceforge.net/) if you don't have one.  To install Dos2Unix, use this command ``` yum install dos2unix ```
* Install [wget](https://www.gnu.org/software/wget/) if you don't have one.  To install wget, use this command ``` yum install wget ```
* Install AWS CLI if you don't have one.  To install AWS CLI, see [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* You should have your private key installed as default in the file id_rsa under ```~/.ssh``` and your public key added in the **authorized_keys** on Node 1.  Otherwise, when calling ssh, you will need to add ```-i yourkey.pem ``` in the ssh command.
* On Node 1, generate the ssh key and copy the public key to Node 2 in the file **authorization_key**.  This is needed when the script using **scp** to copy the tar file from Node 1 to Node 2.
* For AWS CLI working, you also need to have your **Access key ID** and **Secret access key** stored in the file **config** and **credentials** under ```~/.aws```.

## Step 1 - Upgrade Node 1
- Login to your VM VirtualBox session
- Create your desired folder
- Git clone the Confluence using this command ```git clone git@github.dxc.com:Platform-DXC/confluence.git```
- Go to **upgrade script** folder using this command ```cd confluence/code/upgrade/script ```
- Open this file **confluence-upgrade.config** and perform the following:
  - Change the **ENVIR** to one of the following values (DEV, TEST, PROD)
  - Verify the IPs addresses of that **ENVIR** are correct.  If not, make the changes and save.  Below are the examples.
    - ENVIR=TEST
    - TEST_NODE1_PUBLIC_IP=18.234.xx.xxx
    - TEST_NODE1_PRIVATE_IP=172.31.xx.xxx
    - TEST_NODE2_PUBLIC_IP=34.234.xxx.xxx
    - TEST_NODE2_PRIVATE_IP=172.31.xx.xxx
- Verify and make the changes and save for the **current** Confluence version variables.  Below is an example.
  - CONFLUENCE_CURR_VERSION=6.4.3  
- Verify and make the changes and save for the **new** Confluence version variables.  Below are the examples.
  - CONFLUENCE_UPGRADE_VERSION=6.15.2
  - CONFLUENCE_UPGRADE_BINARY=atlassian-confluence-6.15.2-x64.bin
- Start the Confluence upgrade by running this command ```./main-task.sh```
## Step 2 - Replicate Node 1 to Node 2
- To replicate the upgraded Confluence directories from Node 1 to Node 2 in the cluster, run the command ```./second-task.sh```

## Roll back
### Roll back database
To roll back the database, a script needs to restore the RDS snapshot and creates a new database instance.  Following the steps to perform this task by editing this file **rollback-restore-rds-snapshot.sh** and update the following required variables
  - SNAPSHOT_ID="\<enter db snapshot id>"
  - RESTORE_FROM_INSTANCE_ID="\<enter current db instance id>"
  - TARGET_INSTANCE_ID="\<enter new target instance id>"
  - TARGET_INSTANCE_CLASS="\<enter target instance class like 'db.m4.large'>"
  - SUBNET_GROUP_NAME="\<enter VPC subnet group name>"
  - AVAILABLE_ZONE="\<enter available zone>"
  - PUBLICLY_ACCESSIBLE=\<"NO" for not public accessible>

After all of the variables above are correct, run this command ```./rollback-restore-rds-snapshot.sh``` to restore a database from a snapshot.

### Roll back EC2 instance
To roll back the EC2 instance, a script needs to create an AMI Image from EBS 'ROOT' snapshot and then creates an EC2 instance from that image with attached EBS 'OPT' snapshot.

Following the steps to perform this task by editing the following files.
- **rollback-restore-ec2-snapshot.sh** - update the following variables
    - ROOT_SNAPSHOT_ID=""   # this snapshot id is in the file "root-block-device-mapping.json"
    - OPT_SNAPSHOT_ID=""    # this snapshot id is in the file "opt-block-device-mapping.json"
    - IMAGE_NAME=""
    - IMAGE_DESCRIPTION=""
    - IMAGE_ARCHITECTURE="x86_64"
    - IMAGE_ROOT_DEVICE_NAME="/dev/sda1"
    - IMAGE_VIRTUALIZATION_TYPE="hvm"
    - INSTANCE_TYPE=""              
    - INSTANCE_KEY_NAME=""          
    - INSTANCE_SECURITY_GROUP_IDS=""
    - INSTANCE_SUBNET_ID=""      

- **rollback-root-block-device-mapping.json** - Update the json file based on the values derived from the EBS **ROOT** snapshot.  Please make sure the **SnapshotId** has the same value as the variable **ROOT_SNAPSHOT_ID** from above.
- **rollback-opt-block-device-mapping.json** - Update the json file based on the values derived from the EBS **OPT** snapshot.  Please make sure the **SnapshotId** has the same value as the variable **OPT_SNAPSHOT_ID** from above.

After all of the changes above are correct, run this command ```./rollback-restore-ec2-snapshot.sh``` to restore a new EC2 instance from EBS **ROOT** and **OPT** snapshots.

### Update **confluence.cfg.xml**
To update the **confluence.cfg.xml** file with new ip addresses for **cluster peers** and **database connection url**, edit this file **rollback-find-replace-string.sh** and make the changes and run this command ```./rollback-find-replace-string.sh``` to update.

### Things still need to be done
Need to write a script that can perform the following:
- Using AWS CLI to update the target group with new ip addresses
- Get the current EC2 instance information and populate into the variables described above.
- Calling the roll back scripts mentioned above with dynamic variables.
- Unmount the EFS and re-mount to the backup EFS
