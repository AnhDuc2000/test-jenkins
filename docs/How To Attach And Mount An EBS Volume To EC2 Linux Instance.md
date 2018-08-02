# How To Attach And Mount An EBS Volume To EC2 Linux Instance
* Head over to EC2 –> Volumes and create a new volume of your preferred size and type.<br>
* Select the created volume, right click and select the “attach volume” option.<br>
* Select the instance from the instance text box as shown below<br>
* ![Image of Add Volume](Images/add-volume.png)<br>
* login to your ec2 instance and list the available disks using the following command.<br>
* lsblk <br>
* The above command will list the disk you attached to your instance.<br>
* ![Image of lsblk](Images/lsblk.png) <br>
* Check if the volume has any data using the following command. <br>
* sudo file -s /dev/xvdf <br>
* If the above command output shows “/dev/xvdf: data”, it means your volume is empty.<br>
* Format the volume to ext4 filesystem  using the following command. <br>
* sudo mkfs -t ext4 /dev/xvdf <br>
* Create a directory of your choice to mount our new ext4 volume. I am using the name “newvolume” <br>
* Mount the volume to “newvolume” directory using the following command.<br>
* sudo mount /dev/xvdf /newvolume/ <br>
* cd into newvolume directory and check the disk space for confirming the volume mount. <br>
* cd /newvolume <br>
* df -h 
* The above command would show the free space in the newvolume directory.<br>
* ![Image of newvolume](Images/newvolume.png) <br>
* # EBS Automount On Reboot <br>
* By default on every reboot the  EBS volumes other than root volume will get unmounted. To enable automount, you need to make an entry in the /etc/fstab file.<br>
  * 1.	Back up the /etc/fstab file. <br>
      * sudo cp /etc/fstab /etc/fstab.bak <br>
  * 2.	Open /etc/fstab file and make an entry in the following format <br>
      * device_name mount_point file_system_type fs_mntops fs_freq fs_passno <br>
      For example,<br>
      /dev/xvdf       /newvolume   ext4    defaults,nofail  0 0 <br>           
      Execute the following command to check id the fstab file has any error.<br>
      sudo mount -a <br>
  * If the above command shows no error, it means your fstab entry is good. <br>
  * Now, on every reboot the extra EBS volumes will get mounted automatically.<br>
  
  
      

      
      


