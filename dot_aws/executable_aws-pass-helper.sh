#!/bin/bash

# Path where the credentials are stored in pass
BASE_PATH=hosting/aws.amazon.com

# Define the profile from the environment
AWS_PROFILE=${AWS_PROFILE:-default}

# Fetch credentials from pass
ACCESS_KEY_ID=$(pass show $BASE_PATH/$AWS_PROFILE/access_key_id)
SECRET_ACCESS_KEY=$(pass show $BASE_PATH/$AWS_PROFILE/secret_access_key)

# Check that we have the required keys
if [[ -z "$ACCESS_KEY_ID" || -z "$SECRET_ACCESS_KEY" ]]; then
  echo "Error: Missing AWS credentials for profile $AWS_PROFILE" >&2
  exit 1
fi

# Output the credentials in JSON format required by awscli
cat <<JSON
{
  "Version": 1,
  "AccessKeyId": "$ACCESS_KEY_ID",
  "SecretAccessKey": "$SECRET_ACCESS_KEY"
}
JSON
