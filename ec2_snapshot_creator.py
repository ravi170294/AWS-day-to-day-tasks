import boto3
from datetime import datetime

def create_snapshots_for_instances(instance_ids, region='us-east-1'):
    ec2 = boto3.resource('ec2', region_name=region)
    print(f"\n Starting snapshot creation for instances: {instance_ids}")

    for instance_id in instance_ids:
        try:
            instance = ec2.Instance(instance_id)
            print(f"\n Processing instance: {instance_id}")

            for dev in instance.block_device_mappings:
                volume_id = dev['Ebs']['VolumeId']
                device_name = dev['DeviceName']
                print(f" Creating snapshot for volume: {volume_id} (Device: {device_name})")

                snapshot = ec2.create_snapshot(
                    VolumeId=volume_id,
                    Description=f"Snapshot of {volume_id} from {instance_id}"
                )

                snapshot.create_tags(
                    Tags=[
                        {"Key": "Name", "Value": f"{instance_id}-{device_name}"},
                        {"Key": "CreatedBy", "Value": "SnapshotScript"},
                        {"Key": "InstanceId", "Value": instance_id},
                        {"Key": "Date", "Value": datetime.utcnow().strftime("%Y-%m-%d")}
                    ]
                )

                print(f" Snapshot created: {snapshot.id}")
        except Exception as e:
            print(f" Error processing instance {instance_id}: {e}")

if __name__ == "__main__":
    # Get list of instance IDs from user input
    instance_input = input("Enter EC2 Instance IDs separated by spaces: ").strip()
    instance_ids = instance_input.split()

    region = input("Enter AWS region (default: us-east-1): ").strip() or "us-east-1"

    create_snapshots_for_instances(instance_ids, region)
