'''
Performs HTTP request and validates that the response contains expected text.
'''

import os
import sys
from datetime import datetime
from urllib.request import urlopen
import boto3
import logging

# URL of the site to check (environment variable)
SITE_URL = os.environ['SITE_URL']
# Text expected to be found in the response (environment variable)
EXPECTED_TEXT = os.environ['EXPECTED_TEXT']
# Namespace of the metric published to CloudWatch (environment variable)
METRIC_NAMESPACE = os.environ['METRIC_NAMESPACE']
# Name of the metric, within the namespace above, published to CloudWatch (environment variable)
METRIC_NAME = os.environ['METRIC_NAME']

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    validated = False
    logger.info('Checking %s at %s', SITE_URL, event['time'])
    try:
        response = str(urlopen(SITE_URL).read())
        validated = validate(response)
        logger.info('Received response: %s. Validated: %s', response, validated)
    except:
        logger.error('Received error: %s', sys.exc_info()[0])
        raise
    finally:
        publish_metric(validated)


def validate(response):
    return EXPECTED_TEXT in response


def publish_metric(responseSuccessful):
    cloudwatch = boto3.client('cloudwatch')

    metric = [
        {
            'MetricName': METRIC_NAME,
            'Dimensions': [
                {
                    'Name': 'SiteUrl',
                    'Value': SITE_URL
                }],
            'Value': 1 if responseSuccessful else 0,
            'Timestamp': datetime.now(),
            'Unit': 'Count'
        }]

    cloudwatch.put_metric_data( Namespace=METRIC_NAMESPACE, MetricData=metric)
