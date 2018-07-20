# Platform DXC Confluence

Atlassian Confluence is an enterprise wiki tool for use by DXC Technology employees. It provides deep integration with Atlassian JIRA.
**https://confluence.csc.com**

How to instal the confluence automation Test project
  1.Create the Maven project in  eclipse or any Java editor
  1.Clone the project from Github 
  3.Please open the Pom.XML file and refresh and it will create the maven dependecy folder and download all required jar files.
  
How to Test the Confluence Automation Test project
from Jenkins
  1. Login to Jenkins.csc.com
  2. Search the  DevCloud-Confluence-AutoTest job from Jenkins Dashboard
  3. Open the DevCloud-Confluence-AutoTest Job
  4. Click on Build Now option from the Jenkins Dashboard
  5. Once completed you can see the Test result report by clicking the Latest Test Result link which will appear in Jenkin Dashboard
  6. you can see all the Test cases results i.e How many passed and How many failed
  7. For all failed Testcases Jenkins will create the Jira issues and that you can see the in the Latest Test results
  8. Once the issues fixed and re run the job and issues will automcatically resolved if the fix works
  
  Executing the Jenkin Job from Jira
  1. Login into Jira
  2. create a Testcase issue in CZSD project
  3. Click on ExexcuteTestcase transistion and the Jenkin Job will be triggereed
  4. login to Jenkins and see the status of the Job

