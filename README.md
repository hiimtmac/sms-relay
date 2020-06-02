# SMS Relay

How to hook up lambda to receive SMS messages through AWS Pinpoint-SNS-Lambda

## Code

- Clone project
- Install docker (if not installed already)
- Run `build.sh` script
- This will create `lambda.zip` in root of project

## AWS Setup

- Choose AWS region (will refer to it as `AWS_REGION`)
- Get AWS account number (will refer to it as `AWS_ACCOUNT`)
- Get the number you want relayed to (will refer to it as `DESTINATION_NUMBER`)
  - Format number `+XXXXXXXXXXX` (ex: `+12223334444`)

### SNS

- Open `SNS` dashboard
- Select `Topics` menu item
- Select `Create topic` button
  - Choose FIFO (first-in, first-out) type
  - Name it whatever you like (will refer to it as `SNS_TOPIC`)
  - Fill out other optional settings if necessary

### Pinpoint

- Open `Pinpoint` dashboard
- Create a project
- Select `Settings > SMS` menu item
  - Select `Edit` button
    - Enable SMS channel for project
    - Adjust account-level settings as needed
  - Select `Request long codes` button
    - Fill out to request long codes
  - Select number from `Number settings` you wish to use (will refer to it as `PINPOINT_NUMBER`)
    - Open `Two-way SMS`
      - Enable two-way SMS
      - Choose existing SNS topic (`SNS_TOPIC` created earlier)
      - Optionally adjust other settings as needed
  - Get app id of pinpoint project (will refer to it as `PINPOINT_ID`)

### IAM

- Open `IAM` dashboard
- Select `Policies` menu item
  - Select `Create policy` button
    - Service
      - Select `Pinpoint`
    - Actions
      - Select `Write: SendMessages`
    - Resources
      - Select `Specific` radio option
      - Select `Add ARN` button
        - Region: `AWS_REGION`
        - Account: `AWS_ACCOUNT`
        - App id: `PINPOINT_ID`/messages
    - Select `Review policy` button
    - Add policy name (will refer to it as `PINPOINT_POLICY`)
    - Select `Create policy` button
- Select `Users` menu item
  - Select `Add user` button
    - Fill out user name (will refer to it as `IAM_USER`)
    - Choose `Programmatic access` for access type
    - Choose `Attach existing policies directly`
    - Select previously created `PINPOINT_POLICY`
    - Select `Next: Tags` button
    - Optionally add tags as required
    - Select `Next: Review` button
    - Select `Create user` button
    - Select `Download .csv` button to save access key ID (will refer to this as `IAM_ACCESS_KEY_ID`) and secret access key (will refer to this as `IAM_SECRET_ACCESS_KEY`)

### Lambda

- Open `IAM` dashboard
- Select `Create function` button
  - Choose `Author from scratch` option
  - Fill out function name (will refer to it as `LAMBDA_NAME`)
  - Change runtime to `Provide your own bootstrap on Amazon Linux 2`
  - Change default execution role
    - Select `Create a new role from AWS policy templates`
    - Enter role name
    - Choose `Basic Lambda@Edge permissions (for CloudFront trigger)` policy template
  - Adjust advanced settings as needed
  - Select `Create function`
  - Select `+ Add trigger` button
    - Choose `SNS` for trigger configuration
    - Select the SNS topic `SNS_TOPIC` created earlier
  - Under `Funtion code` select `Actions > Upload a .zip file` button
    - Upload `lambda.zip` file from earlier
  - Under `Runtime settings` select `Edit` button
    - Change `Handler` to `Relay` (dont think this isnt needed)
  - Under `Environment variables` select `Edit` button
  - Add environment variables
    - RELAY_AWS_ACCESS_KEY_ID: `IAM_ACCESS_KEY_ID`
    - RELAY_AWS_SECRET_ACCESS_KEY: `IAM_SECRET_ACCESS_KEY`
    - RELAY_DESTINATION_NUMBER: `DESTINATION_NUMBER`
    - RELAY_PINPOINT_APPLICATION_ID: `PINPOINT_ID`

## Summary

Test by sending a text to `PINPOINT_NUMBER`, it should relay it back to you
