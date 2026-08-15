# AWS EC2 Launch Template & Auto Scaling Infrastructure

## Overview

This project provisions a scalable web application infrastructure on AWS using Terraform.

The infrastructure uses an Application Load Balancer, EC2 Launch Templates, an Auto Scaling Group, CloudWatch alarms, IAM, security groups, and a multi-AZ VPC.

The infrastructure is managed entirely through Terraform.

## Architecture

```text
                         Internet
                            |
                            v
                +-----------------------+
                | Application Load      |
                | Balancer              |
                +-----------+-----------+
                            |
                       HTTP :80
                            |
                 +----------+----------+
                 |                     |
                 v                     v
        +----------------+    +----------------+
        | Public Subnet  |    | Public Subnet  |
        | us-east-1a     |    | us-east-1b     |
        |                |    |                |
        | EC2 Instance   |    | EC2 Instance   |
        +--------+-------+    +--------+-------+
                 |                     |
                 +----------+----------+
                            |
                  Auto Scaling Group
                     Min: 2
                     Desired: 2
                     Max: 4
                            |
                     +------+------+
                     |             |
                  Scale Out     Scale In
                  CPU > 70%     CPU < 30%
                     |             |
                     +------+------+
                            |
                       CloudWatch
```

## AWS Resources

The project provisions:

* VPC
* Two public subnets
* Internet Gateway
* Public route table
* Security groups
* IAM role and instance profile
* EC2 Launch Template
* Application Load Balancer
* ALB Target Group
* ALB Listener
* Auto Scaling Group
* CloudWatch alarms
* Auto Scaling policies
* EC2 instances

## Infrastructure

### VPC

The project creates a dedicated VPC using:

```text
10.0.0.0/16
```

DNS support and DNS hostnames are enabled.

### Availability Zones

Availability Zones are discovered dynamically using Terraform:

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

The first two available zones are used for the public subnets:

```hcl
data.aws_availability_zones.available.names[0]
data.aws_availability_zones.available.names[1]
```

This avoids hardcoding Availability Zone names.

### Public Subnets

Two public subnets are used:

```text
10.0.1.0/24
10.0.2.0/24
```

Each subnet is deployed in a separate Availability Zone.

### Internet Gateway

An Internet Gateway provides internet connectivity for the public subnets.

The public route table contains:

```text
0.0.0.0/0 -> Internet Gateway
```

## Application Load Balancer

The Application Load Balancer receives HTTP traffic on port 80 and forwards requests to the EC2 instances registered with the target group.

Traffic flow:

```text
Client
  |
  v
Application Load Balancer
  |
  v
Target Group
  |
  +---- EC2 Instance
  |
  +---- EC2 Instance
```

The ALB uses health checks to determine which instances are available to receive traffic.

## EC2 Launch Template

The Launch Template defines the configuration used by the Auto Scaling Group when launching EC2 instances.

The current configuration includes:

* Amazon Linux 2023
* `t3.micro`
* Security Group
* IAM instance profile
* User data
* Encrypted GP3 EBS volume
* EC2 monitoring
* Resource tags

## Dynamic Amazon Linux AMI

The project does not hardcode an AMI ID.

Terraform searches for the latest matching Amazon Linux 2023 image:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
```

The selected AMI is then passed to the Launch Template.

This allows the infrastructure to use the latest matching image without manually updating an AMI ID.

## User Data

EC2 instances are configured automatically when they launch.

The user data script:

* Installs Apache
* Starts the web server
* Enables the web server
* Retrieves instance metadata
* Creates a test webpage

The test page displays information including:

```text
Instance ID
Hostname
Availability Zone
Private IP
```

This makes it possible to verify that the ALB is distributing requests between different EC2 instances.

## Auto Scaling Group

The Auto Scaling Group manages the EC2 instances.

Current configuration:

```text
Minimum:          2
Desired capacity: 2
Maximum:          4
```

The ASG uses the Launch Template to create instances and registers them with the ALB target group.

ELB health checks are used to help ensure that unhealthy instances are replaced.

## Auto Scaling

CloudWatch monitors CPU utilization.

### Scale Out

When CPU utilization exceeds 70%:

```text
CPU > 70%
    |
    v
CloudWatch Alarm
    |
    v
Scale Out Policy
    |
    v
Additional EC2 Instance
```

### Scale In

When CPU utilization falls below 30%:

```text
CPU < 30%
    |
    v
CloudWatch Alarm
    |
    v
Scale In Policy
    |
    v
EC2 Instance Removed
```

The Auto Scaling Group maintains the configured minimum and maximum instance counts.

## Security

Security Groups control traffic between the load balancer and EC2 instances.

The intended traffic flow is:

```text
Internet
   |
   | HTTP :80
   v
ALB Security Group
   |
   | HTTP :80
   v
EC2 Security Group
   |
   v
EC2
```

EC2 instances use an IAM instance profile rather than storing AWS credentials on the servers.

## Terraform Structure

```text
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── data.tf
├── networking.tf
├── security.tf
├── iam.tf
├── launch_template.tf
├── alb.tf
├── autoscaling.tf
├── terraform.tfvars
│
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── launch_template/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── autoscaling/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── userdata/
    └── install.sh
```

## Terraform Modules

The infrastructure is separated into Terraform modules:

| Module          | Responsibility                                     |
| --------------- | -------------------------------------------------- |
| Networking      | VPC, subnets, route tables and Internet Gateway    |
| Security        | Security Groups                                    |
| IAM             | IAM roles and instance profiles                    |
| Launch Template | EC2 instance configuration                         |
| ALB             | Load balancer, target group and listener           |
| Auto Scaling    | Auto Scaling Group, policies and CloudWatch alarms |

## Terraform Workflow

Initialize Terraform:

```bash
terraform init
```

Format the configuration:

```bash
terraform fmt -recursive
```

Validate the configuration:

```bash
terraform validate
```

Create an execution plan:

```bash
terraform plan
```

Save a plan for deployment:

```bash
terraform plan -out=tfplan
```

Apply the saved plan:

```bash
terraform apply tfplan
```

Destroy the infrastructure:

```bash
terraform destroy
```

## Deployment

The infrastructure is created through Terraform rather than manually configuring individual AWS resources.

Terraform builds the dependency relationship between the components.

The main dependency flow is:

```text
VPC
 |
 +-- Subnets
 |
 +-- Internet Gateway
 |
 +-- Route Tables
 |
 +-- Security Groups
 |
 +-- IAM
 |
 +-- Launch Template
 |
 +-- Application Load Balancer
 |      |
 |      +-- Target Group
 |      |
 |      +-- Listener
 |
 +-- Auto Scaling Group
        |
        +-- EC2 Instances
```

## Testing

After deployment, the ALB DNS name can be used to test the application:

```bash
curl http://<ALB-DNS-NAME>
```

The response should contain information about the EC2 instance serving the request.

Repeated requests can be used to verify that traffic is being distributed across the instances.

Example:

```text
Instance ID: i-xxxxxxxx
Hostname: ip-10-0-x-x
Availability Zone: us-east-1a
Private IP: 10.0.x.x
```

A second instance should return different instance information when traffic is distributed to it.

## High Availability

The application runs across multiple Availability Zones.

```text
                    ALB
                  /     \
                 /       \
          us-east-1a    us-east-1b
              |              |
           EC2 #1          EC2 #2
```

The design avoids relying on a single EC2 instance.

If an instance becomes unhealthy, the ALB can stop sending traffic to it and the Auto Scaling Group can replace it.

## Scalability

The Auto Scaling Group allows the number of EC2 instances to change based on demand.

```text
Normal load
    |
    v
2 instances
    |
    | CPU increases
    v
3 instances
    |
    | CPU increases
    v
4 instances
```

When demand decreases, instances can be removed while respecting the configured minimum capacity.

## Infrastructure as Code

Terraform provides:

* Repeatable deployments
* Version-controlled infrastructure
* Reusable modules
* Consistent configuration
* Automated dependency management
* Easier infrastructure changes
* Reduced manual configuration
* Infrastructure review through Git

## Technologies

| Technology                    | Purpose                |
| ----------------------------- | ---------------------- |
| AWS VPC                       | Network infrastructure |
| AWS EC2                       | Compute                |
| AWS Launch Template           | EC2 configuration      |
| AWS Application Load Balancer | Traffic distribution   |
| AWS Target Groups             | Instance registration  |
| AWS Auto Scaling              | Automatic scaling      |
| AWS CloudWatch                | Monitoring and scaling |
| AWS IAM                       | Access control         |
| Amazon Linux 2023             | EC2 operating system   |
| Terraform                     | Infrastructure as Code |
| Git                           | Version control        |

## Project Status

* [x] Terraform project structure
* [x] AWS provider configuration
* [x] VPC
* [x] Public subnets
* [x] Dynamic Availability Zone discovery
* [x] Internet Gateway
* [x] Route tables
* [x] Security Groups
* [x] IAM configuration
* [x] Dynamic Amazon Linux AMI discovery
* [x] EC2 Launch Template
* [x] User Data
* [x] Application Load Balancer
* [x] Target Group
* [x] ALB Listener
* [x] Auto Scaling Group configuration
* [x] CloudWatch scaling alarms
* [x] Auto Scaling policies
* [ ] Complete EC2 instance deployment
* [ ] Validate ALB traffic distribution
* [ ] Test automatic scale-out
* [ ] Test automatic scale-in

## Future Improvements

* Move EC2 instances into private subnets
* Add NAT Gateway
* Add HTTPS using AWS Certificate Manager
* Add Route 53 DNS
* Add AWS WAF
* Add SSM Session Manager
* Add remote Terraform state using S3
* Add Terraform state locking
* Add CI/CD pipeline
* Add separate development and production environments
* Add CloudWatch dashboards
* Add centralized logging
* Add automated Terraform testing

## Project Goals

The main goals of this project are to demonstrate practical experience with:

* AWS infrastructure design
* Terraform
* Infrastructure as Code
* EC2
* Launch Templates
* Application Load Balancers
* Auto Scaling
* CloudWatch
* IAM
* Security Groups
* Multi-AZ architecture
* Terraform modules
* Automated server configuration
* Troubleshooting AWS infrastructure
* Git-based infrastructure management
