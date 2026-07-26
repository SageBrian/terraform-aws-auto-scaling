#!/bin/bash

# Log all output for troubleshooting
exec > >(tee /var/log/user-data.log | logger -t user-data ) 2>&1

echo "Starting user data script..."

# Update the system
dnf update -y

# Install Apache
dnf install -y httpd

# Enable and start Apache
systemctl enable httpd
systemctl start httpd

# Retrieve an IMDSv2 token
TOKEN=$(curl -X PUT \
"http://169.254.169.254/latest/api/token" \
-H "X-aws-ec2-metadata-token-ttl-seconds:21600")

# Get metadata
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/instance-id)

HOSTNAME=$(hostname)

AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/placement/availability-zone)

LOCAL_IP=$(curl -H "X-aws-ec2-metadata-token:$TOKEN" \
http://169.254.169.254/latest/meta-data/local-ipv4)

# Create a web page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Terraform Auto Scaling Demo</title>
</head>
<body>
    <h1>Terraform Auto Scaling Project</h1>

    <p><strong>Instance ID:</strong> $INSTANCE_ID</p>

    <p><strong>Hostname:</strong> $HOSTNAME</p>

    <p><strong>Availability Zone:</strong> $AVAILABILITY_ZONE</p>

    <p><strong>Private IP:</strong> $LOCAL_IP</p>

</body>
</html>
EOF

echo "User data completed."