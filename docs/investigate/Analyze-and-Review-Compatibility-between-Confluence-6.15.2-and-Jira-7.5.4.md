# Analyze and Review Compatibility between Confluence 6.15.2 and Jira 7.5.4

This documentation is for analyzing and reviewing the compatibility between Confluence 6.15.2 and Jira 7.5.4.

The latest Confluence Data Center release is version 6.15.x.  Both Confluence 6.15.x (AppLinks 5.4.7) and JIRA 7.5.x (AppLinks 5.4.1) have the same major and minor version of AppLinks.  For details, see the [Applinks compatibity chart](https://confluence.atlassian.com/applinks/application-links-version-matrix-779174762.html).

On this ticket [CSP-249386](https://getsupport.atlassian.com/servicedesk/customer/portal/14/CSP-249386), it said "Since Confluence 6.15.x and Jira 7.5.x are both supported according to our Atlassian Support End of Life Policy, the application links are supported and will work together.  Since this is a new version of Confluence there is no information currently on compatibility issues.

To get familiar with the changes, please see the following:

* For Confluence release notes, see [here](https://confluence.atlassian.com/doc/confluence-release-notes-327.html).

* For Confluence 6.15 support platforms, see [here](https://confluence.atlassian.com/doc/supported-platforms-207488198.html).

* For Confluence Upgrade Matrix, see [here](https://confluence.atlassian.com/doc/confluence-upgrade-matrix-960695895.html)

## Questions to discuss about Java JDK:
Current Confluence 6.4.3 is using Oracle JDK 1.8.0_77.  Starting in January 2019, Java SE commercial users must buy a license in order to receive update.  For detail, see [here](https://upperedge.com/oracle/using-java-heres-how-oracles-new-2019-java-se-licensing-affects-you/).

Oracle JDK 1.8.0_202 is the last Java 8 update ([Critical Patch Update](https://www.oracle.com/technetwork/topics/security/alerts-086861.html) – 8u201, and the related 8u202 [Patch Set Update](https://www.oracle.com/technetwork/java/javase/cpu-psu-explained-2331472.html]) available under the [BCL license](https://java.com/license) was released on January 15th, 2019.  For detail, see [here](https://jaxenter.com/end-line-java-8-public-updates-154182.html)

### Which Java vendor can I use with my Confluence version? 
The following table lists the supported Java vendors, and whether Oracle or AdoptOpenJDK is bundled with Confluence.  For detail, see [here](https://confluence.atlassian.com/doc/change-the-java-vendor-or-version-confluence-uses-962342397.html).

| Confluence version | Supported Java vendors | Bundled Java vendor |
| ------------------ | ---------------------- | ------------------- |
| 6.6.12 and earlier | Oracle JRE | Oracle JRE |
| 6.7.0 to 6.13.1, and 6.14.0 | Oracle JRE | Oracle JRE | 
| 6.13.2 to 6.13.x, and 6.14.1 and later | Oracle JDK/JRE & AdoptOpenJDK | AdoptOpenJDK |

**Known issue**: AdoptOpenJDK does not include a required font configuration package, which may cause issues when installing in Linux. See [Confluence Server 6.13 or later fails with FontConfiguration error when installing on Linux operating systems](https://confluence.atlassian.com/confkb/confluence-server-6-13-or-later-fails-with-fontconfiguration-error-when-installing-on-linux-operating-systems-960167204.html). 