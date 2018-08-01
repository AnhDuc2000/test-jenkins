# Test Content

This folder contains tests for the project.

For more information about testing within Platform DXC, and the guidelines we try to align to, see the [testing repository](https://github.dxc.com/Platform-DXC/testing).

## Manual Testing

Our primary testing mechanism at the moment is manual testing, though we intend to improve this through our [DevOps Test Automation Theme](../docs/DevOpsThemes/ImprovementTheme-TestAutomation.md).

To enable a user to be able to test, they must first have a User ID created on the JIRA PenTest System with their DXC _short name_.  JIRA acts as an authentication source for Confluence.

In addition, the user must then be granted access to Confluence (`confluence-users` group). In most cases for our team this will be to the administrators group (`confluence-administrators`).

## Manual Unit Testing

Before testing, it is recommended to open a Chrome Incognito or Microsoft Edge/IE InPrivate browser window. This starts you fresh with no cookies/previous login info, and better replicates a brand new user.

* TEST-UNIT-1 Display login screen
    - Access your given URL. See [architecture](../docs/architecture.md) for a list of URLs.
    - Expect to quickly see a page that presents a box which says: "Select Identity Provider, What kind of user are you?, DXCGLOBALPASS DXCGLOBALPASS, Login with username and password"
    - The page stops here.
    - Verify the Confluence version in the footer of this page is 5.9.5
    - Verify the dropdown menu at far top left has these values:
        * JIRA
        * Confluence
        * Artifactory
        * Confluence (note - Yes, this is a duplicate in current production)
        * Github
        * Jenkins
        * sonarqube
    - This is a success of this step, do not worry about any further redirection or entering credentials.

* TEST-UNIT-2 Login with User ID and Password
    - Access your given URL. See [architecture](../docs/architecture.md) for a list of URLs.
    - Expect to quickly see a page that presents a box which says: "Select Identity Provider, What kind of user are you?, Select or wait 3 seconds to use DXCGLOBALPASS,DXCGLOBALPASS DXCGLOBALPASS, Login with username and password"
    - You must click "Login with username and password" within three (3) seconds.

* TEST-UNIT-3 Logout
    - Click your user profile at top right, and select Log Out.
    - Expect to quickly see a page that presents a box which says: "Select Identity Provider, What kind of user are you?, Select or wait 3 seconds to use DXCGLOBALPASS,DXCGLOBALPASS DXCGLOBALPASS, Login with username and password"
    - You should be automatically logged back in.  (it is not acutally possible to stay logged out)

* TEST-UNIT-4 View Confluence Spaces
    - After logging in, click "Spaces" in the top navigation and select "Space Directory".
    - You should see a list of spaces.
    - If you scroll to the bottom, you should see at least nine (9) separate pages listed. ("Prev 1 2 3 4 5 6 7 8 9 Next")

* TEST-UNIT-5 Search Confluence Space
    - Click the search box at the top right
    - Search for the word "CPS Upgrade"
    - You should see at least 1700 results.
    - The first result should be a space called "CPS Upgrade", with a small circle space icon.
    - CLick the "CPS Upgrade" space.
    - You should see the "CPS Upgrade" spac ehomepage titled "CPS Upgrade Home".

* TEST-UNIT-6 View Add Ons
    - After logging in, click the Administration "cog wheel" at the far top right, and choose "Add Ons".
    - Prompted to re-enter your password.
    - See a page titled, "Managed Add Ons" and select "All add-ons"
    - Review [pre-upgrade screenshot](confluence-5.9.5-screen-captures/ConfluenceAdminManageAddOnsAllAddOns.pdf).

* TEST-UNIT-7 Backup Administration
    * After logging in, click the Administration "cog wheel" at the far top right, and choose "General Configuration".
    * Prompted to re-enter your password.
    * Search and select "Backup Administration" via left-hand navigation
    * Review [Backup Admin screenshot](confluence-5.9.5-screen-captures/ConfluenceAdminBackupAdmin.pdf).

* TEST-UNIT-8 Clustering
    - After logging in, click the Administration "cog wheel" at the far top right, and choose "General Configuration".
    - Prompted to re-enter your password.
    - Search and select "Clustering" via left-hand navigation
    - Review [Clustering screenshot](confluence-5.9.5-screen-captures/ConfluenceAdminClustering.pdf)

* TEST-UNIT-9 External Gadgets
    * After logging in, click the Administration "cog wheel" at the far top right, and choose "General Configuration".
    * Prompted to re-enter your password.
    * Search and select "External Gadgets" via left-hand navigation
    * Review [External Gadgets screenshot](confluence-5.9.5-screen-captures/ConfluenceAdminExternalGadgets.pdf)

* TEST-UNIT-10 General Configuration
    - After logging in, click the Administration "cog wheel" at the far top right, and choose "General Configuration".
    - Prompted to re-enter your password.
    - Search and select "General Configuration" via left-hand navigation
    - Review [General Configuration screenshot](confluence-5.9.5-screen-captures/ConfluenceAdminGeneralConf.pdf)

* TEST-UNIT-11 Hip Chat Integration
    - After logging in, click the Administration "cog wheel" at the far top right, and choose "General Configuration".

    - Prompted to re-enter your password.

    - Search and select "Hip Chat Integration" via left-hand navigation

    - Review [Hip Chat Integration screenshot](confluence-5.9.5-screen-captures/ConfluenceAdminHipChatIntegration.pdf)

## Other Tests Recommended by Atlassian for Post-Upgrade Checking
Refer to: <https://confluence.atlassian.com/conf64/confluence-post-upgrade-checks-936511832.html>

* TEST-ATLASSIAN-1 Layout and Menu
  * Visit the Confluence dashboard and check that it is accessible and displays as expected. 
  * Test the different Internet browsers (IE, Firefox, Chrome)
  * In addition, confirm that the layout appears as expected and that the menus are clickable and functioning.
* TEST-ATLASSIAN-2 Search
  * In upper right-corner, search (via magnifying glass) for "Customer Zero Desk" and select "Customer Zero Service Desk Home"
    * This should take you to [https://confluence.csc.com/display/CZSD/Customer+Zero+Service+Desk+Home](https://confluence.csc.com/display/CZSD/Customer+Zero+Service+Desk+Home)
  * Search for "tester1"
    * This should take you to [https://confluence.csc.com/dosearchsite.action?queryString=tester1](https://confluence.csc.com/dosearchsite.action?queryString=tester1)
* TEST-ATLASSIAN-3 Permissions
  * Logout and login as "tester1" into Confluence [Confluence](https://confluence.csc.com) using user name / password
  * Go to [https://confluence.csc.com/display/CZSD/View+Restrictions](https://confluence.csc.com/display/CZSD/View+Restrictions)
    * Confirm that you can visit a page that has view restrictions, but you cannot edit the page
  * Go to [https://confluence.csc.com/display/CZSD/Editing+allowed](https://confluence.csc.com/display/CZSD/Editing+allowed)
      *  Confirm that you can view and edit the page
  * Go to [https://confluence.csc.com/display/CZSD/No+editing+or+viewing+allowed](https://confluence.csc.com/display/CZSD/No+editing+or+viewing+allowed)
      * Confirm that you do do not have permission to view this page
* TEST-ATLASSIAN-4 Attachments
    *  Confirm that attachments are accessible and searchable. 

## Automated Testing

* Go to [here](ConfluenceAutomationTest/Readme.md) for instructions on running the automated test cases and follow the information on executing the test cases within JIRA. 

## Unit Testing

Please describe the tools used and how you are managing unit test generation and execution, linting, syntax checking, spell checking documentation, and variations of this for the languages in scope.


## Integration Testing

Please describe the tools used and how you are managing integration test generation and execution

* TEST-INT-1 Login with SAML Single Sign-On (DXC GlobalPass)
    - Access your given URL. See [architecture](../docs/architecture.md) for a list of URLs.
    - Expect to quickly see a page that presents a box which says: "Select Identity Provider, What kind of user are you?, Select or wait 3 seconds to use DXCGLOBALPASS,DXCGLOBALPASS DXCGLOBALPASS, Login with username and password"
    - After three seconds, you should be redirected either to a) a black and yellow DXC GlobalPass login screen, or b) directly to your Confluence homepage.
* TEST-INT-2 Integration with JIRA?

## Functional Testing

Please describe your functional tests and how they are being traced to insure requirements are met, any test-driven / behavior-driven development approaches

### Build

Was the build successful, If successful, did it work or respond?

### Deployment

Describe how the deployment is validated

## Regression Testing

Regression testing has several meanings.  When addressing backwards compatibility we expect that is handled in functional testing and that the regression testing is focused on avoiding re-entry of prior bugs by forcing the testing against prior bugs.  Please describe the methods used by the team to address this testing practice.

## Load / Performance Testing

Please describe how your team is addressing load testing and what the expected loads will look like and any performance profiles related.
