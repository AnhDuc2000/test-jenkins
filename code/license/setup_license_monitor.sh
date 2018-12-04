#!/bin/bash

printf "\nSetup up Confluence License Monitor\n"

printf "\nChecking for an existing AtlassianLicenseMonitoringPolicy..."
policyARN=`aws iam list-policies --query "Policies[?PolicyName=='AtlassianLicenseMonitoringPolicy'].Arn" --output text`

if [ -z "$policyARN" ]; then

printf "\nNot found, so creating policy..."
aws iam create-policy \
  --policy-name AtlassianLicenseMonitoringPolicy \
  --description "Used to allow Atlassian License query Lambda to put metric data into CloudWatch and log the Lambda function" \
  --policy-document "$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
)"

    policyARN=`aws iam list-policies --query "Policies[?PolicyName=='AtlassianLicenseMonitoringPolicy'].Arn" --output text`

    printf "created!\n"

else

    printf "found it!\n"

fi



printf "\nChecking for an existing AtlassianLicenseMonitoringRole..."
roleARN=`aws iam list-roles --query "Roles[?RoleName=='AtlassianLicenseMonitoringRole'].Arn" --output text`

if [ -z "$roleARN" ]; then

printf "\nNot found, so creating role..."
aws iam create-role \
  --role-name AtlassianLicenseMonitoringRole  \
  --description "Used to allow Atlassian License query Lambda to put metric data into CloudWatch" \
  --assume-role-policy-document "$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
)"


    roleARN=`aws iam list-roles --query "Roles[?RoleName=='AtlassianLicenseMonitoringRole'].Arn" --output text`

    printf "created!\n"

else

    printf "found it!\n"

fi

printf "\nAttaching policy to the role..."
aws iam attach-role-policy \
  --role-name AtlassianLicenseMonitoringRole  \
  --policy-arn "$policyARN"
  

printf "\nPackaging up the code for AWS Lambda..."

printf "\nNOTE: Requires zip to be installed; you may have to run sudo apt install zip\n"

mkdir packagetmp
cp lambda_function.py packagetmp
# TODO: Given use of the botocore.vendored, this next line isn't necessary anymore
#pip install requests -t packagetmp/
cd packagetmp
zip lambda_function.zip *
mv lambda_function.zip ..
cd ..
rm -rf packagetmp

printf "\nCreating the Lambda function..."
aws lambda create-function \
  --function-name "AtlassianConfluenceLicenseMonitor" \
  --runtime "python3.6"\
  --role "$roleARN" \
  --handler "lambda_function.lambda_handler" \
  --zip-file fileb://lambda_function.zip \
  --description "Queries the Atlassian Confluence REST API to collect license metrics, and then puts them into CloudWatch for tracking." \
  --tags '{"application-id":"confluence","group":"doe","ooss-compliance":"TBD","environment":"prod","owner":"dc294a64.CSCPortal.onmicrosoft.com@amer.teams.ms"}'

rm lambda_function.zip

#print "\nScheduling the Lambda function..."

#aws events put-rule \
#--name AtlassianLicenseMonitoringRule \
#--schedule-expression 'rate(6 hours)'

#aws lambda add-permission \
#  --function-name "AtlassianConfluenceLicenseMonitor" \
#  --statement-id

# Create the targets.json
#cat "foo" > targets.json

#aws events put-targets \
#  --rule "AtlassianLicenseMonitoringRule" \
#  --targets file://targets.json

