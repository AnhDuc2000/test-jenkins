Confirm AWS Account Ansible Role
================================

This role can be used to confirm that the AWS keys (credentials) used for
interacting with AWS resources correspond to the AWS account they are intended
to be used for.

The role allows to prevent situations where the execution is done using a set
of AWS keys that does not correspond to the inventory being used. For example, the
role will fail if the AWS keys used are for PROD account but the inventory used
during the execution corresponds to DEV account. Without this check it would be
possible to apply changes with DEV inventory to PROD account, which is usually
a human mistake.

Configuration
-------------

The role requires a hash called `params` with the following entries:
* `aws_account_id` - ID of AWS account that needs to correspond to the AWS keys
  being used

