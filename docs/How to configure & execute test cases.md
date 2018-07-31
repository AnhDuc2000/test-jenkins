# How to configure the Jenkins job for Executing Confluence Test cases
## Prerequisites for configure the jenkins
 * Chrome driver (down load from http://chromedriver.chromium.org/) <br>
 * Copy the chrome driver in C:\Chrome folder
 * Install TestNG & Junit and Jira Testresult reporter plugins 
## How to create a job in Jenkins
Login into Jenkins using DXC global credentials using below URL <br>
https://jenkins.csc.com <br>
Once login to Jenkins ,click on New Item from Jenkins <br>
![Image of New Job](https://github.dxc.com/Platform-DXC/confluence/tree/DOE-237/docs/Images/New-Item.png) <br>
Enter the Job name as _"Devcloud-confluence-AutoTest"_   and select the Maven job and click on Ok and please click on below image for more information <br>
![Image of configure Job](https://github.dxc.com/Platform-DXC/confluence/tree/DOE-237/docs/Images/New-job.png)  <br>
## Configure the source code management  <br>
select the git from the source code management and enter the below details
  * Repository URL	 ->git@github.dxc.com:Platform-DXC/confluence.git
  * Credentials -> Select the credentials from the list 
  * Branch Specifier (blank for 'any')	-> */DOE-236
  * Additional Behaviours -> check out to a sub-directory
     * Local subdirectory for repo -> tests/tests/ConfluenceAutomationTest <br>
![Image of source code](https://github.dxc.com/Platform-DXC/confluence/tree/DOE-237/docs/Images/Sourcecode.png) 
## Configure the build environment <br>
Goto Add Build step <br>
Select the Execute Windows Batch Command <br>
Enter the below code into the text area <br>
 D:\Jenkins\tools\hudson.tasks.Maven_MavenInstallation\custzero-maven\bin\mvn.cmd -f D:\Jenkins\jobs\DevCloud-Confluence-AutoTest\workspace/tests/ConfluenceAutomationTest/tests/ConfluenceAutomationTest/pom.xml clean install && exit %%ERRORLEVEL%% 
<br>
## Configure for publish junit test result report & Generating the Jira issues for failed test cases
Goto post build action section <br>
select publish Junit test result report <br>
Enter the test report xml path in Test report XMLs	text box -> <b>"**/junitreports/TEST-pacConfluenceTest.ConfluenceAutoTest.xml"</b><br>
In Additional test report features	section configure the Jira project and issue type <br>
  * Project Key	-> Select the Project Key of the Jira project
  * Issue Type -> Select Bug from the issue type list
  * Checked Auto raise issues	
  * Checked Auto Auto resolve issues	
  <br>![Image of Junit configuration](https://github.dxc.com/DXC-Jira-Confluence/ConfluenceTestcaseAutomation/tree/master/Images/Junit.png)
## Configure TestNg reports
Goto post build action section <br>
select publish TestNg Results <br>
Enter the path of TestNg report file <br>
TestNG XML report pattern	 -> **/testng-results.xml <br>
![Image of TestNG configuration](https://github.dxc.com/Platform-DXC/confluence/tree/DOE-237/docs/Images/TestNG.png)
## Apply & Save
After configuring the above steps click on Apply and save <br>
The new job confluenceAutomationTest wil be create and you can see in Jenkins Dashbiard.
