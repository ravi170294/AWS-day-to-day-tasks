#!/bin/bash

# Ask user to enter comma-separated Volume IDs
read -p "Enter EBS Volume IDs (comma-separated): " volume_input

# Convert input into an array
IFS=',' read -ra volume_ids <<< "$volume_input"

echo "Checking and deleting EBS volumes..."

for volume_id in "${volume_ids[@]}"; do
    volume_id=$(echo "$volume_id" | xargs)  # Trim whitespace
    echo "Processing Volume ID: $volume_id"

    # Get the volume state
    state=$(aws ec2 describe-volumes --volume-ids "$volume_id" \
        --query "Volumes[0].State" --output text 2>/dev/null)

    if [[ "$state" == "available" ]]; then
        echo "Volume $volume_id is in 'available' state. Deleting..."
        aws ec2 delete-volume --volume-id "$volume_id"
        echo "Deleted volume $volume_id."
    elif [[ "$state" == "in-use" ]]; then
        echo "⚠️ Volume $volume_id is 'in-use'. Skipping deletion."
    elif [[ -z "$state" ]]; then
        echo "❌ Volume $volume_id not found or invalid ID."
    else
        echo "⚠️ Volume $volume_id is in '$state' state. Skipping."
    fi

    echo "--------------------------------------"
done

echo "✅ Script complete."
