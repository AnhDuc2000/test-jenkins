# Objective of Document
- The main objective of this document is to measure how time it would take to export and import the confluence into test system
- Based on the information we can plan for production.
- we divided the tasks into 2 categories <br>
      1) The spaces which are integrated with Jira <br>
      2) The spaces which are not integrated with Jira <br>
 - This document will cover the spaces which are not integrated with Jira
 ## Migration Plan for CPS space which are not integrated with Jira
 - Identify the spaces in CPS production system which are not integrated with Jira and upload the spaces into SharePoint portal.
 - Identify the users for the above spaces
 - Identify the user groups for the spaces and create the groups in Jira (Since confluence using Jira directory) and onboard the users into CPS Test System.
- Once users groups & users onboarded process is completed (In Test system we are not creating the groups and adding the confluence-user group to all spaces and providing the access), download the spaces from SharePoint portal and import the same into CPS Test system 
- During the import the groups & users will added to confluence spaces by system.
- Ask the CPS confluence users to verify whether all pages and links properly imported.

 ## Measure Time & Size of the spaces
 
 - In the first phase we tested the below spaces and it will give you high-level estimation for the rest of the spaces. The import will slightly vary in production because that will depend on Network bandwidth and usage of the system during the import.
- The time taken for import is not based on the size of the file, it would depend on no pages, no of blogs, no of links. In the below spaces the file which have 2.6 GB is completed in 6 min whereas the file with size 333 MB had taken 9 min.

 

| Space Name     | Size of the space| Time taken to export  | Time taken to Import|
|----------------|------------------|-----------------------|---------------------|
| VSA		 | 2.6 GB	    |  135 Min	            |  6 min             |
| AAT       	 | 7 MB		    |  2 Min	            |  3 min             |
| APACHED	 | 16 MB	    |  3 Min	            |  3 min             |
| NAT		 | 297 MB	    |  25 Min	            |  8 min             |
| Serviced	 | 333 MB	    |  25 Min	            |  9 min             |
| WI		 | 2.97 GB	    |  140 Min	            |  10 min             |
| ENGAPPSEXPANSION| 2 MB	    |  2 Min	            |  2 min             |
