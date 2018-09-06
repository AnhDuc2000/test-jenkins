Setup URL Monitor Ansible Role
==============================

This role is used to setup URL monitor and an alert triggered when the monitor fails.

It creates the following AWS resources:
* Lambda function used to connect to HTTP(S) URL and checking whether the
  response contains configured text. The function records configured CloudWatch
  metric with value of `1` for successful check and `0` for failure.
* IAM role required by the lambda function above.
* CloudWatch schedule used to trigger the lambda function based on configured
  period.
* CloudWatch alert triggered when availability metric populated by lambda
  function falls under configured threshold.
* SNS topic with SMS subscriptions where alerts are published.

Configuration
-------------

The role uses a set of parameters defined within `params` hash and having the
following keys:
* `monitor_name` - name of the monitor used to create various resources.
* `site_url` - URL to monitor. If URL connection results in HTTP code other
  than 200 a `0` metric value will be recorded. Otherwise the expected text
  below will be checked.
* `expected_text` - text to look for in the HTTP response. If the text can be
  found it will result in `1` metric value, `0` otherwise.
* `metric_namespace` - CloudWatch metric namespace. Should be
  `PlatformDXCDevOps` for DevOps Framework metrics.
* `metric_name` - name of the CloudWatch metric. Should be an assertion that
  the monitor is ok, e.g. `JiraStatusOK`
* `schedule_expression` - how often the URL check should be performed. Can
  either use AWS rate or cron expression.
* `alarm_period` - how often (number of seconds) the metric should be checked
  to determine it violates the threshold.
* `alarm_evaluation_periods` - how many times the metric needs to be at `0`
  before the alert is triggered.
* `alarm_description` - CloudWatch alarm description.
* `sms_topic_name` - name of SNS topic where alerts get published.
* `sms_topic_display_name` - short name of the alert that will be used as
  prefix in SMS messages, e.g. `JIRA ALERT`.
* `sms_topic_subscriptions` - a list (can be empty - `[]`) of SMS
  subscriptions. Each item of the list must have `endpoint` and `protocol:
  "sms"` elements.
  * `endpoint` - country code prefixed, international phone number, e.g.  `+1234567890`
  * `protocol` - must be `sms`

Known Issues
------------

### SMS/Text Message Type

AWS can send 2 types of SMS messages - promotional (default) and transactional.

During the tests we noticed that promotional SMS text messages were not
successfully delivered to India.

In our case SMS text messages are sent as a result of CloudWatch alert firing
and posting alert message to SNS topic, which then results in SMS text messages
being sent to the subscribers of that topic. We did not find any way to
configure the alert or the SNS topic or its subscriptions, using Ansible, to
ensure the SMS text message type is transactional.

This can be done in AWS console by changing text messaging preferences. Note
that this change applies defaults to the entire AWS account.

To change the SMS text message default type go to AWS console and do the
following:
* Go to SNS page
* Click on the _Text Messaging (SMS)_ in the left navigation
* Click on _Manage text messaging preferences_
* Change default message type to _transactional_
