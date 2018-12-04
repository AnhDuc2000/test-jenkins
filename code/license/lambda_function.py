import boto3
# when testing locally
#import requests
# when live in AWS Lambda
from botocore.vendored import requests
import json
import os
import base64

# Required Environment Variables
# CONF_ENV = Environment name, used for the metric dimensions. Since the accounts are separate, this is a bit extraneous.
# CONF_HOST = Host name of the JIRA Host to hit, not including protocol
# CONF_API_SECRET = The API Secret, base64 encoded.  Note this is NOT a secure storage mechanism.

# Comment out this line when testing locally, put it back when testing in
def lambda_handler(event, context):

    # Get the environment to use when building the CloudWatch dimensions
    sEnvironment = os.environ['CONF_ENV']

    # Dynamically build the URL string

    #https://confluence.csc.com/rest/license/1.0/license/userCount
    #https://confluence.csc.com/rest/license/1.0/license/remainingSeats
    #https://confluence.csc.com/rest/license/1.0/license/maxUsers

    # First value

    sURL = "https://" + os.environ['CONF_HOST'] + "/rest/license/1.0/license/userCount"
    api_response = requests.get(sURL, auth=requests.auth.HTTPBasicAuth("LicenseMonitor", base64.urlsafe_b64decode(os.environ['CONF_API_SECRET']).decode('utf-8') ) )

    if (api_response.status_code == 200):
        data = api_response.json()
        licensedUserCount = data["count"]
    else:
        raise ValueError ( 'Could not load license details for userCount due to HTTP Response Code ' + str(api_response.status_code) )

    # Second value - actually no tnecessary for our reporting, as it can be calculated with the other two

    #sURL = "https://" + os.environ['CONF_HOST'] + "/rest/license/1.0/license/remainingSeats"
    #api_response = requests.get(sURL, auth=requests.auth.HTTPBasicAuth("LicenseMonitor", base64.urlsafe_b64decode(os.environ['CONF_API_SECRET']).decode('utf-8') ) )
    #
    #if (api_response.status_code == 200):
    #    data = api_response.json()
    #    licensedRemainingSeats = data["count"]
    #else:
    #    raise ValueError ( 'Could not load license details for remainingSeats due to HTTP Response Code ' + str(api_response.status_code) )

    # Third value

    sURL = "https://" + os.environ['CONF_HOST'] + "/rest/license/1.0/license/maxUsers"
    api_response = requests.get(sURL, auth=requests.auth.HTTPBasicAuth("LicenseMonitor", base64.urlsafe_b64decode(os.environ['CONF_API_SECRET']).decode('utf-8') ) )

    if (api_response.status_code == 200):
        data = api_response.json()
        licensedMaxUsers = data["count"]
    else:
        raise ValueError ( 'Could not load license details for maxUsers due to HTTP Response Code ' + str(api_response.status_code) )

    # When debugging locally...
    #print ("licensedUserCount: ", licensedUserCount, "\n" )
    ##print ("licensedRemainingSeats: ", licensedRemainingSeats, "\n" )
    #print ("licensedMaxUsers: ", licensedMaxUsers, "\n" )
    #exit()

    # Now that we have the data...

    # BUG TODO: The sEnvironment doesn't process directly as it's somehow wrapped inside this pseudo-JSON.
    # I can only get it to work by removing sEnvironment.

    # Post it to AWS CloudWatch
    cloudwatch = boto3.client('cloudwatch')
    response = cloudwatch.put_metric_data(
        MetricData = [
            {
                'MetricName': 'ConfluenceLicensedUserCount',
                'Dimensions': [
                    {
                        'Name': 'Environment',
                        'Value': sEnvironment
                    },
                ],
                'Unit': 'None',
                'Value': licensedMaxUsers
            },
            {
                'MetricName': 'ConfluenceActiveUserCount',
                'Dimensions': [
                    {
                        'Name': 'Environment',
                        'Value': sEnvironment
                    },
                ],
                'Unit': 'None',
                'Value': licensedUserCount
            },
        ],
        Namespace = 'PlatformDXCDevOps'
    )
