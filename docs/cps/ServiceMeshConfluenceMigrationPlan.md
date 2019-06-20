# ServiceMesh Confluence Migration DOE Confluence Instance

## Overview
* This document will detail a high level serviceMesh migration plan for Confluence. We will migrate data from ServiceMesh Confluence Cloud site to our DevOps Enablement Confluence instance. 
* It encompasses using the backup manager at the server level to import a snapshot exported from ServiceMesh Confluence Cloud site.

### Pre-migration steps

* Check that you have System Administrator global permissions in DOE Confluence System, and Site Administrator permissions in your ServiceMesh Cloud site.
* ServiceMesh Confluence Users and Groups are created on DOE Confluence System
* Backup DOE Confluence DB by performing a snapshot prior to the start of migration.
* Work with and notify users prior to migration effort
* Determine duplicate spacekeys and rename or move to a different name


### Systems

* [DOE Confluence](https://confluence.csc.com)
* [Confluence Cloud](https://dxcconfluence.atlassian.net)


### Assumptions

* Required plug-ins and versions are compared and aligned
* Backup Manager is configured for Export and Import.


## Perform Analysis and Cleanup of both CONFLUENCE Services
* Spot check at end of the day
* Re-index at end of day (NOTE: Emeka ask Tien how)
  * Perform on whichever node on DOE Confluence administrator has access
  * Stop that node service from within server
  * Zip up index files 
  * Startup the service again
  * Bring down service on the other node
  * Copy the indexes
  * Restart the service on the other nodee

## Performing Migration of Waves of Spaces
### Create Backup - creates export file - on ServiceMesh Cloud site 
* Steps to export and download as .xml file to local computer 
  * Select Spaces.
  * Search and Select a space to export
  * Select Space Settings
  * Select Content Tools
  * Select Export
  * Choose XML and click NEXT
  * Choose Full Export.
  * Click Export.
  * Click Download afer export is completed 
  * Download snapshot to your local computer
  * Make the ServiceMesh space read-only and inform users, if necessary
  * NOTE
    * Migration of smaller batch of up to 500mb will be done on the UI
    * Migrating a medium batch of 500mb up to 1000mb will also be done through the UI
    * Space larger than 1000mb will be moved to the DOE Confluence server restore directory and import will pickup the file from there

* Upload Snapshot on destination system
  * Navigate to destination system to General Configuration
  * Select Backup Manager
  * Select Backup & Restore
  * Uncheck index button as we will reindex at end of day
  * Select import in the UI. 
    * If it is a large file
      * Select the imported zip file from list if using the server restore directory filesystem
  * Check Content Indexing as file imports

### Post-Migration

* Review migrated data of confluence server to ensure the data and attachments have migrated successfully. 

* Check spaces for common things, e.g.: comments, attachments, and permissions.
* Allow time for different teams and users to test the operation and functionality of the application to identify any behavior gaps. If needed, we may want to document them for our users.