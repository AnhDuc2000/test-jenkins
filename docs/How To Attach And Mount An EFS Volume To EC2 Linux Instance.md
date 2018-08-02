## How To Attach And Mount An EFS To EC2 Linux Instance
* 1.	Login to AWS web console <br>
* 2.	Select Elastic File System <br>
* 3.	Select Create file system <br>
* 4.	Select VPC <br>
* 5.	Select Private subnets that the EC2 Instances are on for the availability zones <br>
* 6.	Remove the default security group from each availability zone <br>
* 7.	Paste or start typing the EFS Security Group ID in for each availability zone <br>
* 8.	Select Next Step <br>
* 9.	Add Name Tag and any others <br>
* 10.	Select Generic or Max I/O type <br>
* 11.	Select Next Step <br>
* 12.	Select Create file system <br>
# How to cofigure in AWS <br>
* Search the EFS (managed file storage for EC2) from services <br>
* ![Image of EFS](Images/efs.png) <br>
* Click on create file system from above screen <br>
* ![Image of Create file System](Images/createFS.png) <br> 
* Select the VPC and select the availability zones from the list <br>
* ![Image of Create file System](Images/cfs2.png) <br>
* Enter the value for choose the other values and click on next <br>
* Review the changes and click on crate file system <br>
* ![Image of Create file System](Images/efs3.png) <br>
# Install Dependencies <br>
1.NFS utilities <br>
  a.	sudo yum -y install nfs-utils <br>
2.	amazon-efs-utlis <br>
  a.	sudo yum -y install git <br>
  b.	git clone https://github.com/aws/efs-utils <br>
  c.	Because you need the bash command make, you can install it with the following command if your operating system doesn't already have it.<br>
  d.	sudo yum -y install make <br>
  e.	After you clone the package, you can build and install amazon-efs-utils using one of the following methods, depending on the package type supported by your Linux distribution: <br>
  f.	RPM – This package type is supported by Amazon Linux, Red Hat Linux, CentOS, and similar.<br>
  g.	DEB – This package type is supported by Ubuntu, Debian, and similar.<br>
 
# To build and install amazon-efs-utils as an RPM package <br>
  1.	Open a terminal on your client and navigate to the directory that has the cloned amazon-efs-utils package from GitHub (for example "/home/centos/efs-utils").<br>
  2.	If you haven't done so already, install the rpm-builder package with the following command.<br>
  3.	sudo yum -y install rpm-build<br>
  4.	Build the package with the following command.<br>
      sudo make rpm <br>
  5.	Install the amazon-efs-utils package with the following command. <br>
  6.	sudo yum -y install ./build/amazon-efs-utils*rpm <br>
# Get DNS URL <br>
    1.	Open EFS Web Console  <br>
    2.	Select the newly created EFS <br>
    3.	Click on the DNS Names hyperlink on bottom left <br>
   ![Image of file system access](Images/fsa.png) <br>
# Manual Mount <br>
 * Use the below command for manual mount.<br>
 * sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-55645d1d.efs.us-east-1.amazonaws.com:/ efs <br>
 * type df -h command you can see the mount attached to efs.
 * ![Image of DF](Images/df.png) <br>
# Auto mount <br>
 * If you reboot the system and the mount will be deleted and if the mount make available even the system reboot , we need to update the fstab file.<br>
 * Take the backup of fstab file (\etc\fstab) <br>
 * Cp fstab fstab.bak <br>
 * Open the fstab file add the below line and save the file <br>
    * mount-target-DNS:/ efs-mount-point nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport 0 0 <br>
    * us-east-1a.fs-55645d1d.efs.us-east-1.amazonaws.com:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0 <br>
    * Reboot the system using sudo reboot command and run the df -h command you can see the mount point and it will not be deleted.  <br>
    *  ![Image of DF](Images/Df1.png) <br>
