#!/bin/bash

# Ask for AWS region
read -p "Enter AWS region (e.g. ap-south-1): " region

# Ask for description value to match
read -p "Enter description keyword to search for: " keyword

echo "🔍 Searching snapshots with description containing: '$keyword'..."

# Get snapshots with matching description
snapshot_ids=$(aws ec2 describe-snapshots \
    --region "$region" \
    --owner-ids self \
    --query "Snapshots[?contains(Description, \`$keyword\`)].SnapshotId" \
    --output text)

if [ -z "$snapshot_ids" ]; then
    echo "❌ No snapshots found with description containing '$keyword'."
    exit 1
fi

echo "✅ Found the following snapshots to delete:"
echo "$snapshot_ids"

# Confirm deletion
read -p "Are you sure you want to delete these snapshots? (yes/no): " confirm

if [[ "$confirm" == "yes" ]]; then
    for snap_id in $snapshot_ids; do
        echo "🗑️ Deleting snapshot: $snap_id"
        aws ec2 delete-snapshot --snapshot-id "$snap_id" --region "$region"
    done
    echo "✅ All snapshots deleted successfully."
else
    echo "❎ Deletion aborted."
fi
