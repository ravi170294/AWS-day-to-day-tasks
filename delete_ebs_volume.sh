#!/bin/bash

# List of volume IDs passed as arguments
volume_ids=("$@")

# Check if volume IDs were provided
if [ ${#volume_ids[@]} -eq 0 ]; then
  echo "Usage: $0 <volume-id-1> <volume-id-2> ... <volume-id-N>"
  exit 1
fi

# Loop through each volume ID
for volume_id in "${volume_ids[@]}"; do
  echo "Checking volume: $volume_id"

  # Get the volume state using AWS CLI
  state=$(aws ec2 describe-volumes --volume-ids "$volume_id" \
    --query "Volumes[0].State" --output text)

  if [ "$state" == "available" ]; then
    echo "Deleting volume: $volume_id (State: available)"
    aws ec2 delete-volume --volume-id "$volume_id"
  else
    echo "Skipping volume: $volume_id (State: $state)"
  fi
done
