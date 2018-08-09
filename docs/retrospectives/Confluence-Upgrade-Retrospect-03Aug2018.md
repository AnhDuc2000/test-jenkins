### **Retrospect on Confluence grade on 8/3/18**

#### What went well

1.  Team used MS Teams for communication and implementation progress
2.   Team was well prepared for implementation 
3.   Team did multiple test runs prior to implementation
4.   Created numerous shell scripts which reduced manual typing & typos
5.   Team had an ongoing edit on implementation guide to capture changes made and had to react to during the implementation
6.  Automated test suites plus a consolidated test document reduced testing time 
7.  Team was able to determine root cause of Global Pass issue quickly during implementation, which helped point GP to how to fix

#### What did not go well

1.  Global Pass prod configuration keyed off of user_emailid instead of user_shortname as it was done in pentest

2. Radhika was not the correct person to resolve GP Prod issues.  Had to contact Raj Antony (US) to fix PROD.

3.  Some scripts did not run in Prod but did on Pentest

4.  India network (folks working from home) impacted our resolution turnaround time

   

#### Action Plan

1. Global Pass:

   - add GP configuration test suite (verify receiving shortname vs email, API ?) --  **add user story**
   - For future implementations, engage with Raj Antony (GP Prod) instead of Radhika
   - Test against GP Prod, not GP Pentest

2. fix implementation scripts with issues  (see implementation plan update for details).  Change to pull latest copy from GitHub and upload to server -- **add user story**

3. Replace all manual edits from implementation plan to scripts -- **add user story**

4. post installation customized files should be posted in GitHub (no passwords) -- **add user story**

5. Research Zero Downtime for both Jira/Confluence -- **add user story**

    

   