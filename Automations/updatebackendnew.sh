#!/bin/bash

get_instance_id() {
  TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" \
    -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

  curl -sH "X-aws-ec2-metadata-token: $TOKEN" \
    http://169.254.169.254/latest/meta-data/instance-id
}


# Set the Instance ID and path to the .env file
# INSTANCE_ID="i-030da7d31a1dbbffc"
INSTANCE_ID=$(get_instance_id)


# Retrieve the public IP address of the specified EC2 instance
ipv4_address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

# Path to the .env file
file_to_find="../backend/.env.docker"

# Check the current FRONTEND_URL in the .env file
current_url=$(sed -n "4p" $file_to_find)

# Update the .env file if the IP address has changed
if [[ "$current_url" != "FRONTEND_URL=\"http://${ipv4_address}:5173\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${ipv4_address}:5173\"|g" $file_to_find
    else
        echo "ERROR: File not found."
    fi
fi
