# Confluence Upgrade 6.4 to 6.15 Review

This is a temporary review of all of the release notes from Confluence 6.4.x through to 6.15.x to understand any nuances to user impact, upgrade impact, or other considerations we need to make.

## Background

* Current Version: `Confluence 6.4.3`
* [Confluence Release Notes](https://confluence.atlassian.com/doc/confluence-release-notes-327.html) - main page linking off to major releases and other sub-release notes.
* [Upgrade Matrix](https://confluence.atlassian.com/doc/confluence-upgrade-matrix-960695895.html) - Summarized list of key changes and bug fixes.
* For each version, review both the Release Notes & the Upgrade Notes.

## Summary

* User Impact
  * Visual enhancements
  * Improved `Edit Files` feature, replacing the old `Edit in Office` feature
  * Improved editor updates
  * Numerous bug fixes and performance enhancements
* System Impact
  * Move to new JDK
  * Update to web-based unit tests (e.g., UI updates may break some more brittle UI tests, opportunity to move to less brittle tests such as API)
  * `web.xml` changes to support mobile app in 6.8, may require we ensure these updates are applied
  * Possible risk of "Not enough space on disk" errors due to lack of available inodes in Linux OS, would need to be mitigated
  * Possible risk of font challenges, would need to be mitigated (installing additional Linux apps)
* Other Awareness
  * "Add Ons" renamed to "Apps"

## Review

* Confluence 6.5
  * New notifications
  * Improved attachment index performance
  * Possible risk: change of attachment performance based on opening caching/metadata files in the attachment folders.  Possible risk of "No enough space on disk" errors. If we receive these errors, here's the fix:
  * https://confluence.atlassian.com/doc/confluence-6-5-upgrade-notes-938862633.html
  * Recommends reapplying changes to:
    * `server.xml`
    * `setenv.sh`
    * `confluenceinit.properties`
  * Make sure to run Support Tools > health check
* Confluence 6.6
  * Nothing
* Confluence 6.7 - https://confluence.atlassian.com/doc/confluence-6-7-upgrade-notes-943529899.html
  * Introduces @ tagging users
  * Fresh new look (USER AWARENESS)
  * New icons
  * Numbering column option moved
* Confluence 6.8
  * Color scheme changes to the default scheme, but ONLY if they have been left default. Anything customized won't change.
  * More visual updates
  * Performance enhancements
  * Web.xml changes to support the new mobile app
* Confluence 6.9
  * Introduced CalDAV interface for Team Calendars
* Confluence 6.10
  * Data center introduces Read Only mode to support upgrades
  * Search improvements
  * Memory sandbox for processor intensive operations, requires 2GB free
  * Tomcat is upgraded from 8 to 9
* Confluence 6.11
  * Improved file editing of attachments to a page using the appropriate desktop app.  Replaces "Edit in Office".
    > "We've removed the 'Edit in Office' button from the attachments page, the View Files macro and the Attachments macro."
  * Recommended if users are using the Edit in Office feature, sending them the new Edit Files docs: https://confluence.atlassian.com/doc/edit-files-170494553.html
  * Support zip generation newly available via API
* Confluence 6.12
  * Generate support zips on different notes through admin GUI
  * Changes to how the system manages PDF exports
  * New editor icons
  * "Add Ons" renamed to "Apps"
* Confluence 6.13
  * Support for AdoptOpenJDK 8 - https://confluence.atlassian.com/doc/change-the-java-vendor-or-version-confluence-uses-962342397.html
    * We should use the bundled Java version, which is the AdpotOpenJDK, and future Confluence releases will thus also upgrade Java for us.
  * Enhancements to support GDPR for deleting a user
  * Migration assistant to move data to the Atlassian Confluence Cloud
* Confluence 6.14
  * Enhanced search; will look different to end users, replacing quick search with a pop box of larger search results.
  * "Massive Editor improvements"
* Confluence 6.15
  * Improved admin backup & restore page

## Other Notes

After upgrade, we need to undo the disabling we did for the CVE security setting exposed on 6.4.3 version.
(this is the security issue released in April 2019) Placeholder to put into the specific release process we'll need.
