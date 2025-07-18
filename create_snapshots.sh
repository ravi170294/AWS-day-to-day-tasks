#!/bin/bash

# Prompt for region
echo -n "Enter AWS region (e.g. ap-south-1): "
read region

# Prompt for EC2 instance IDs
echo -n "Enter EC2 Instance IDs (space-separated): "
read -a instances

echo "📋 Creating snapshots in region: $region"

for instance_id in "${instances[@]}"; do
    echo -e "\n🔍 Processing instance: $instance_id"

    # Get volume IDs for the instance
    volume_ids=$(aws ec2 describe-instances \
        --instance-ids "$instance_id" \
        --region "$region" \
        --query "Reservations[].Instances[].BlockDeviceMappings[].Ebs.VolumeId" \
        --output text)

    for volume_id in $volume_ids; do
        echo "🧱 Creating snapshot for volume: $volume_id"
        
        # Create snapshot and get snapshot ID
        snapshot_id=$(aws ec2 create-snapshot \
            --volume-id "$volume_id" \
            --description "Snapshot of $volume_id from $instance_id" \
            --region "$region" \
            --query SnapshotId \
            --output text)

        # Tag the snapshot
        aws ec2 create-tags \
            --resources "$snapshot_id" \
            --region "$region" \
            --tags Key=Name,Value="${instance_id}-${volume_id}" \
                   Key=CreatedBy,Value=SnapshotScript \
                   Key=InstanceId,Value="$instance_id"

        echo "✅ Snapshot created: $snapshot_id"
    done
done
