#!/bin/bash

set -o errexit -o pipefail

echo "-------------------------------------------------"
echo " Restore RDS Snapshot and create an db instance  "
echo "-------------------------------------------------"
echo ""

# Need to enter Snapshort Id here - REQUIRE"
SNAPSHOT_ID="<enter db snapshot id>"                # example: "confluence-snap-19-05-08-14-00-1557324009"

RESTORE_FROM_INSTANCE_ID="<enter restore from instance id>" # example: "cps-confluence-050719"
TARGET_INSTANCE_ID="<enter new target instance id>"     # example: "confluence-upgrade-yyyy-mm-dd"
TARGET_INSTANCE_CLASS="<enter target instance class>"  # example: db.m4.large
SUBNET_GROUP_NAME="<enter VPC subnet group name>"   # example: "default" on pentest; "xxxdevclouddbsubnet" on production
AVAILABLE_ZONE="<enter available zone>"             # example: "us-east-1a"
PUBLICLY_ACCESSIBLE "NO"

echo "Checking for an existing instance with the identifier '${TARGET_INSTANCE_ID}'"
EXISTING_INSTANCE_ID=$( aws rds describe-db-instances --db-instance-identifier $TARGET_INSTANCE_ID --query 'DBInstances[0].[DBInstanceIdentifier]' --output text )

if [ "${EXISTING_INSTANCE_ID}" == "${TARGET_INSTANCE_ID}" ];
then
    if [ "${TARGET_INSTANCE_ID}" == "${RESTORE_FROM_INSTANCE_ID}" ];
    then
        echo "Error: Target instance id '${TARGET_INSTANCE_ID}' is the same as restore from instance id '${RESTORE_FROM_INSTANCE_ID}'."
        exit 1;
    fi
    echo "Error: An existing instance found with the same target instance id '${TARGET_INSTANCE_ID}'"
    exit 1;
fi

echo "Restoring snapshot '${SNAPSHOT_ID}' to a new db instance '${TARGET_INSTANCE_ID}'..."
aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier $TARGET_INSTANCE_ID \
    --db-snapshot-identifier $SNAPSHOT_ID \
    --db-instance-class $TARGET_INSTANCE_CLASS \
    --db-subnet-group-name $SUBNET_GROUP_NAME \
    --availability-zone $AVAILABLE_ZONE \
    --no-multi-az \
    --publicly-accessible $PUBLICLY_ACCESSIBLE \
    --auto-minor-version-upgrade


while [ "${exit_status}" != "0" ]
do
    echo "Waiting for '${TARGET_INSTANCE_ID}' to be 'available'..."
    aws rds wait db-instance-available --db-instance-identifier $TARGET_INSTANCE_ID
    exit_status="$?"

    INSTANCE_STATE=$( aws rds describe-db-instances --db-instance-identifier $TARGET_INSTANCE_ID --query 'DBInstances[0].[DBInstanceStatus]' --output text )
    echo "'${TARGET_INSTANCE_ID}' instance state is: ${INSTANCE_STATE}"
done
echo "Finished creating instance '${TARGET_INSTANCE_ID}' from snapshot '${SNAPSHOT_ID}'"

echo "Updating instance '${TARGET_INSTANCE_ID}' identifier"
aws rds modify-db-instance \
    --db-instance-identifier $TARGET_INSTANCE_ID \
    --apply-immediately

aws rds wait db-instance-available --db-instance-identifier $TARGET_INSTANCE_ID
echo "Finished updating '${TARGET_INSTANCE_ID}'"

echo "Created instance '${TARGET_INSTANCE_ID}' from snapshot '${SNAPSHOT_ID}' successful!!"

exit 0