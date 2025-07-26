#!/bin/bash

# Check if volume ID is passed as argument
if [ -z "$1" ]; then
  echo "Usage: $0 <volume-id>"
  exit 1
fi

VOLUME_ID=$1

echo "Checking status of volume: $VOLUME_ID"

# Get volume state using AWS CLI
VOLUME_STATE=$(aws ec2 describe-volumes \
  --volume-ids "$VOLUME_ID" \
  --query "Volumes[0].State" \
  --output text)

if [ $? -ne 0 ]; then
  echo "Error fetching volume information. Please check the volume ID or AWS CLI config."
  exit 1
fi

echo "Volume state: $VOLUME_STATE"

if [ "$VOLUME_STATE" == "available" ]; then
  echo "Deleting volume: $VOLUME_ID ..."
  aws ec2 delete-volume --volume-id "$VOLUME_ID"

  if [ $? -eq 0 ]; then
    echo "Volume $VOLUME_ID deleted successfully."
  else
    echo "Failed to delete volume $VOLUME_ID."
  fi
else
  echo "Volume $VOLUME_ID is in '$VOLUME_STATE' state. Only 'available' volumes can be deleted."
fi
