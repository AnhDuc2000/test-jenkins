# Collecting Atlassian Confluence License Counts

## Overview

The license collection mechanism runs as an AWS Lambda function using Python, that connects to the Confluence REST API, collects key pieces of license data, and publishes it to AWS CloudWatch.

The Confluence REST API for our current version of Confluence is not as advanced as JIRA, and thus 

This example makes use of AWS IAM, AWS Lambda, AWS CloudWatch, and AWS CloudTrail.

## Environment Variables

The following Environment Variables need to be deined on the Lambda function:

* CONF_ENV = Environment name, used for the metric dimensions. Since the accounts are separate, this is a bit extraneous.
* CONF_HOST = Host name of the Confluence Host to hit, not including protocol
* CONF_API_SECRET = The API Secret, base64 encoded

## Authentication

Setup a user called LicenseMonitor, giving it a complex password.  Base64 that password locally by typing:

```
go64.py
```

## Authentication with OAuth (not currently functioning)

The JIRA REST API uses OAuth Authentication.  To set this up, open Administration > Application Links.

```bash
openssl genrsa -out jiralicense_privatekey.pem 1024
openssl req -newkey rsa:1024 -x509 -key jiralicense_privatekey.pem -out jiralicense_publickey.cer -days 365
openssl pkcs8 -topk8 -nocrypt -in jiralicense_privatekey.pem -out jiralicense_privatekey.pcks8
```

When generating the cert, choose: US, VA, Tysons, DXC Technology, then blank for all remaining fields.

* jira_home: `https://jirapentext.dxcdevcloud.net`
* Consumer Key: `OauthKey`

use the `pki\jiralicense_publickey.pem` file when configuring the Application Link

## Setup

Making sure your AWS credentials are setup for the AWS CLI, simply run the setup batch file:

```bash
setup_license_monitor.sh
```

After this runs you will need to,

* Add environment vars to the Lambda function: CONF_HOST, CONF_ENV, and CONF_API_SECRET. Note, the API Secret for now is common across both the JIRA and Confluence License Lambda functions as they use the same account.
* Setup (or reuse!) the LicenseMonitor account in Confluence and set a complex password. Put the user in the `confluence-administrators` and `confluence-users` user groups to obtain the proper permissions. Then login with the password to make sure the CAPTCHA is not set and the user can login.
* Setup a schedule by modifying the Lambda to run off a CloudWatch event. Click triggers, select CloudWatchEvents, and under rule selection, reuse the AtlassianLicenseMonitorRule which is common to both JIRA and Confluence Lambda functions. It is recommended to run every 3 hours, though the period can be adjusted.

## Debugging and Testing Locally

To debug and test the code locally, comment out the

```python
def lambda_handler(event, context):
```

You will need to change the intending for the remaining code as Python is strict about this.

Add the required environment variables to your local environment (e.g., `export FOO=BAR`), and then run the code like this:

```bash
python3 lambda_function.py
```

When ready to put back into AWS Lambda, you simply return the `def lambda_handler()` method header and re-indent the code.

## To Do

* Document how to setup the CloudWatch rate(3 hour) rule in the .sh script. For now set it up manually.
* Refactor the packaging, since it's no longer needed since using the botocore requests import (available by default in Lambda). This is partially done, though still doing via ZIP which is likely not necessary.
* Refactor to OAuth, preferably v2
* Rerunning the setup script should overwrite the Lambda function to a new version, but it seems not working at the minute.

## Troubleshooting

* If response code is HTTP 403, it's possible the account is locked out. Authenticate using the password to make sure the user is not being challenged for a CAPTCHA.
* If response code is HTTP 401, the user may not have the proper group permissions to login. Validate the user's group assignments.

## Reference

* https://developer.atlassian.com/server/jira/platform/oauth/
* https://stackify.com/custom-metrics-aws-lambda/   
* http://blog.appliedinformaticsinc.com/how-to-get-authorize-and-request-access-token-for-jira/
