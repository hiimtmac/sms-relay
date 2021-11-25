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
- Get the number you want relayed to (will refer to it as `OWNER_NUMBER`)
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
  - Select number from `Number settings` you wish to use (will refer to it as `RELAY_NUMBER`)
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
- Select `Roles` menu item
  - Select `Create role` button
    - Attach previously created `PINPOINT_POLICY`
    - Attach `AWSLambdaBasicExecutionRole` 

### Lambda

- Open `Lambda` dashboard
- Select `Create function` button
  - Choose `Author from scratch` option
  - Fill out function name (will refer to it as `LAMBDA_NAME`)
  - Change runtime to `Provide your own bootstrap on Amazon Linux 2`
  - Change default execution role, choose role created above
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
    - OWNER_NUMBER: `OWNER_NUMBER`
    - RELAY_NUMBER: `RELAY_NUMBER`
    - PINPOINT_APP_ID: `PINPOINT_ID`

## Summary

Test by sending a text to `PINPOINT_NUMBER`, it should relay it back to you
