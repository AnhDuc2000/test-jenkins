# Confluence DevOps Improvement Theme: Test Automation

## Current State/Problem

* Testing of Confluence and JIRA are very similar, because Confluence relies on JIRA as it's authentication source for User IDs and both systems are web based from the same vendor.
* Testing is almost exclusively performed manually, without any consistency from one test to another.
*  Testing is generally performed by administrators with elevated administrator access, which may not always mimic the experience a "traditional" user of Confluence may see.
* Testing of DXC GlobalPass is currently done from our test systems to a GlobalPass test system. This means users must be explciitly setup in a GlobalPass test database, and to date the number of users we can setup for testing is limited
* There is value in testing User IDs and passwords, especially where that enables validation and isolation of GlobalPass, however there have been issues where certain elements have not been discovered prior to production upgrades because they were not tested explicitly in the pre-prod environment.
* Testing currently is limited to functional/unit/integration, but not performance, resiliency, chaos monkey, etc.

* Ravi Balusu from DevCloud team is currently working to [automate web testing of Confluence with DOE-236](https://jira.csc.com/browse/DOE-236).  This involves Java code, using the [Selenium project](https://www.seleniumhq.org/) and a [Chrome webdriver](http://chromedriver.chromium.org/), as well as integrating with DevCloud Jenkins for automation and JIRA for issue reporting.

* At times, the team has been challenged from clearly testing a before or an after system, and knowing which results should be expected for each.  It is more about identifying differences, reviewing them, and adjusting to them.

## Definition of Awesome

Description.

## Next Target Condition

In X weeks, we will have changed/upgraded/improved/deployed.

## First Steps

This section outlines the next three steps the team will take to get to the next target condition.

1.
2.
3.
