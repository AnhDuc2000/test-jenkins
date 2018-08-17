# Confluence Operations Manual

Table of Contents

* [Overview](#overview)
* [OUCH - Outage Update Checklist for Happiness](#ouch---outage-update-checklist-for-happiness)
* [Vendor Support](#vendor-support)
* [Security and Access Control](#security-and-access-control)
* [Monitoring and Alerting](#monitoring-and-alerting)
* [Operational Tasks](#operational-tasks)
* [Failure and Recovery](#failure-and-recovery)
* [Maintenance Tasks](#maintenance-tasks)
* [Backup and Restore](#backup-and-restore)
* [Contact Details](#contact-details)
* [Onboarding Access](#onboarding-access)

## Overview

> Application overview.
> Reference to `ARCHITECTURE.md` that contains infrastructure diagram and components
> for each of the environments.
> Reference to detailed information provided by the vendor.
> Application URLs.

## OUCH - Outage Update Checklist for Happiness

> What needs to be done in which order to start recovery (e.g. post Workplace message,
> log vendor ticket, do X, do Y)

The details about various communication channels are available in [Communication Plan](https://github.dxc.com/pages/Platform-dxc/docs/posts/devops-communication-plan/).

## Vendor Support

Vendor support is provided by Atlassian, though the same support channels as JIRA.  We have a Support Entitlement Number SEN-6941251.

Associated with this number are separate technical contacts and billing contacts.  Amanda Noble is the primary for both.

You must first register for a support account, and then request one of the existing contacts to add your account as an additional contact, which they can do at this page: https://my.atlassian.com/product

To contact the vendor directly for high-priority issues, use this link:  https://my.atlassian.com/products/requestsupport/6941251.  It includes our license ID, and will take you directly to a page to open a support request.

## Security and Access Control

Confluence uses Atlassian Crowd, which is a centralized single sign-on provider that is actually hosted by our [JIRA instance](https://github.dxc.com/platform-dxc/jira/). In effect, configuring JIRA for single sign-on, and then Confluence with Crowd pointing to JIRA, means Confluence users can use DXC GlobalPass.

In addition, we also support external user access control.

In addition, Confluence uses the same internal directly as JIRA, however has its own set of database tables.

> Administrative access to the application - what is it needed for, how to use it.
> Infrastructure access - what is it needed for, how to use it.
> Example: where I could SSH from to the application server X.

## Monitoring and Alerting

> Where are the alert notifications sent.
> When I get an alert what do I do (action)?
> What are _false positive_ alerts for the application?
> What are the healthchecks to validate the application is running?

## Operational Tasks

> Recurring/routine tasks - either a reference to a step-by-step procedure or
> how to invoke the automated task.

## Failure and Recovery

> How to start/stop application components.
> How to failover.
> How to validate the application works after failover (re: healthchecks above).
> Troubleshooting failover and recovery.

## Maintenance Tasks

> Patching.
> New version deployment - how to use the pipeline (location, access, parameters).

## Backup and Restore

> What is backed up and how.
> What is RTO (recovery time objective)?
> What is RPO (recovery point objective - how much time/data we'll lose)?
> Restore procedure.

## Contact Details

> Who to call and how in case of major issue.

Ravi Balusu - IST
Jay Shain, Tien Van Nguyen - PST
Adam Harvey - EST

## Onboarding Access

> What's needed to get administrative access to the application.
> What's needed to get infrastructure access to the application.
