Absolutely. This is actually a good point to pause the infrastructure work and document what we've built so far.

For a **recruiter-facing portfolio project**, the README should communicate more than "I created an ASG." It should show that you understand **AWS architecture, Terraform, Infrastructure as Code, high availability, security, auto scaling, and operational considerations**.

I would also include a professional architecture diagram.

![Image](https://images.openai.com/static-rsc-4/lLVfZmNKm1abeJj3-wPQDnRQRmQXv8cs7SFs5KafuwaAiP6hzXRiGCjBWv7ppHd3fiq1QUC72-yEmoJO8G28h0PNRw1HjAZPYEQ_GqkOV2Q5akgBvpVHM9Of9SNel1_AU6NMQa9P2uztPKRj73NgB0AdaiCiwx7YNhR19zGmPUHBCDlKwh-LE77Pnwmy_KJP?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/dXxAvPtzmU51CB9D3aAELiweINtPOdwEUL4_qYHYOXAjhMyWrErKLsLslQlkJDJhdrs2Fs-j-lMN5vj6EYFrS6ICNx6gZU_rppS90YLPUrZXXwK2sKStdYN-NNMPkb4rgFpwRrbhI_-Ziy5OHAAxVjVebpPRCU2hN74Yq3-yQ3B-JGhwWaCFhvr83wv3fCeh?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/SqercZUwfkuC1DrCOg8ofFEkMinU90644r4f9XAwt1yoKqf0o6uJa1WyDQFSaS93myolWMwAB4npsqOrYQveo3LzPIdyRou8ME-KF6g0ub1JnxveBhDXqozzNoFauVwWCKTyQzuUgw0KEi-X68lVKTwGkggDBVaBjgx8J7Hd-k7NoUzYgEfyoMS9BysA264x?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/N5VpNke7_8fgUThZiJ3itS2FOPoUw2aw4ueReiHTUiAXJIwqDquzlgzNo0DBFK7VbDTqvj3cJspH6uTYqk79Xwq5YCACGeeEsJ8h5tv3M-DgzwYIPbq9qbrT6oCkeEZtKehLtMZK_3LdzT80ygUD7jt_N-tLCkgZ98feEo8V-nc_7yoLK7sQ5iImcE3N4DWv?purpose=fullsize)

![Image](https://images.openai.com/static-rsc-4/uPHyJn-_5NOT8PmJCSKarciEMG9vG_A7pfelrnTLCWWVA8MqVJJexdMP90qa87yDsksl87NudYTwYktwsKTNCTElyZiZ-mGAPyr0gYspbkdbNpWpIw6NiAyZ7D1Taik5wvI9t3SRrx3g-FDDxvtLOop2-OymGsdtw7v62nZ3qRzTweR0K-M8UsXmltz1xT6L?purpose=fullsize)

## Recommended README

Create/update:

```text
README.md
```

with the following:

````markdown
# AWS EC2 Launch Template & Auto Scaling Infrastructure

![AWS](https://img.shields.io/badge/AWS-Cloud-orange)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-7B42BC)
![EC2](https://img.shields.io/badge/AWS-EC2-blue)
![Auto%20Scaling](https://img.shields.io/badge/AWS-Auto%20Scaling-orange)
![ALB](https://img.shields.io/badge/AWS-Application%20Load%20Balancer-orange)

## Overview

This project provisions a highly available and automatically scalable web application infrastructure on AWS using Terraform.

The infrastructure is designed around an Application Load Balancer, an EC2 Launch Template, and an Auto Scaling Group distributed across multiple Availability Zones.

The entire environment is provisioned and managed through Terraform rather than manually creating resources through the AWS Management Console.

The project demonstrates practical cloud engineering concepts including:

- Infrastructure as Code
- AWS networking
- EC2 Launch Templates
- Application Load Balancing
- Auto Scaling
- IAM
- Security Groups
- CloudWatch monitoring
- Dynamic AMI discovery
- Multi-AZ architecture
- Automated instance configuration
- Terraform modules
- Infrastructure validation and deployment

---

# Architecture

```text
                         Internet
                            |
                            |
                    +-------v-------+
                    |      ALB      |
                    | Application   |
                    | Load Balancer |
                    +-------+-------+
                            |
                     HTTP :80
                            |
                +-----------+-----------+
                |                       |
                v                       v
        +---------------+       +---------------+
        |  Public       |       |  Public       |
        |  Subnet AZ-1  |       |  Subnet AZ-2  |
        |               |       |               |
        |   EC2 #1      |       |   EC2 #2      |
        +-------+-------+       +-------+-------+
                |                       |
                +-----------+-----------+
                            |
                     Auto Scaling Group
                            |
                 +----------+----------+
                 |                     |
             Scale Out             Scale In
             CPU > 70%             CPU < 30%
                 |                     |
                 v                     v
             CloudWatch            CloudWatch
               Alarm                 Alarm
````

The infrastructure is deployed inside an AWS VPC with resources distributed across multiple Availability Zones.

---

# Architecture Components

## 1. Amazon VPC

The project creates a dedicated VPC:

```text
CIDR: 10.0.0.0/16
```

The VPC provides network isolation for the application infrastructure.

DNS support and DNS hostnames are enabled to support AWS service discovery and EC2 networking.

---

## 2. Public Subnets

Two public subnets are created across separate Availability Zones.

Example:

```text
10.0.1.0/24
10.0.2.0/24
```

Availability Zones are dynamically discovered using a Terraform data source instead of being unnecessarily hardcoded.

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

The subnets use:

```hcl
data.aws_availability_zones.available.names[0]
data.aws_availability_zones.available.names[1]
```

This makes the configuration more reusable across environments.

---

# 3. Internet Gateway

An Internet Gateway provides internet connectivity for the public subnets.

The public route table contains:

```text
0.0.0.0/0 -> Internet Gateway
```

This allows resources in the public subnets to communicate with the internet.

---

# 4. Application Load Balancer

An AWS Application Load Balancer distributes incoming HTTP traffic across healthy EC2 instances.

The ALB:

* Runs across multiple Availability Zones
* Listens on HTTP port 80
* Uses a Target Group
* Performs health checks
* Routes requests only to healthy instances

Traffic flow:

```text
Client
  |
  v
ALB :80
  |
  v
Target Group
  |
  +----> EC2
  |
  +----> EC2
```

---

# 5. EC2 Launch Template

The Launch Template defines how EC2 instances should be created.

It includes:

* Amazon Linux 2023
* `t3.micro` instance type
* IAM instance profile
* Security Group
* User data
* Encrypted EBS storage
* Detailed monitoring
* Resource tagging

The Launch Template acts as the blueprint used by the Auto Scaling Group.

---

# 6. Dynamic Amazon Linux AMI

Instead of hardcoding an AMI ID, Terraform dynamically retrieves the latest Amazon Linux 2023 AMI.

Example:

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

This prevents the infrastructure from depending on an outdated AMI ID.

---

# 7. User Data

EC2 instances are automatically configured at launch using a user-data script.

The script installs and starts the web server and generates a simple test page containing instance information.

The page is useful for demonstrating that requests are being distributed across multiple EC2 instances.

Example information displayed:

```text
Instance ID
Hostname
Availability Zone
Private IP
```

This makes the load-balancing behavior easy to verify.

---

# 8. Auto Scaling Group

The Auto Scaling Group manages the EC2 fleet.

Current configuration:

```text
Minimum: 2
Desired: 2
Maximum: 4
```

This provides baseline redundancy while allowing the infrastructure to scale when required.

The ASG:

* Uses the Launch Template
* Spans multiple Availability Zones
* Registers instances with the ALB Target Group
* Uses ELB health checks
* Replaces unhealthy instances
* Supports automatic scaling

---

# 9. Auto Scaling Policies

CloudWatch monitors EC2 CPU utilization.

### Scale Out

When CPU utilization exceeds:

```text
70%
```

the scale-out policy increases the number of instances.

```text
CPU > 70%
     |
     v
CloudWatch Alarm
     |
     v
Scale Out
     |
     v
ASG +1 Instance
```

### Scale In

When CPU utilization falls below:

```text
30%
```

the scale-in policy reduces the number of instances.

```text
CPU < 30%
     |
     v
CloudWatch Alarm
     |
     v
Scale In
     |
     v
ASG -1 Instance
```

Cooldown periods are used to prevent rapid repeated scaling actions.

---

# 10. IAM

The project uses IAM to control EC2 permissions.

The EC2 instances receive permissions through an IAM instance profile rather than embedding AWS credentials inside the server.

This follows AWS security best practices.

The project also uses the AWS Auto Scaling service-linked role for Auto Scaling service operations.

---

# 11. Security Groups

Security Groups provide network-level access control.

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

The EC2 instances should not need to accept arbitrary HTTP traffic directly from the internet.

Instead, application traffic should flow through the Load Balancer.

---

# Terraform Structure

The project uses a modular Terraform structure:

```text
terraform/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── data.tf
│
├── networking.tf
├── security.tf
├── iam.tf
├── launch_template.tf
├── alb.tf
├── autoscaling.tf
│
├── terraform.tfvars
│
├── modules/
│   │
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

---

# Terraform Workflow

The infrastructure follows a standard Terraform workflow.

## Initialize

```bash
terraform init
```

## Format

```bash
terraform fmt -recursive
```

## Validate

```bash
terraform validate
```

## Generate a Plan

```bash
terraform plan
```

For controlled deployments, the plan can be saved:

```bash
terraform plan -out=tfplan
```

## Apply

```bash
terraform apply tfplan
```

## Destroy

When the environment is no longer required:

```bash
terraform destroy
```

---

# Deployment Process

The infrastructure is deployed in dependency order by Terraform.

Terraform determines the dependency graph automatically.

For example:

```text
VPC
 |
 +--> Subnets
 |
 +--> Internet Gateway
 |
 +--> Route Tables
 |
 +--> Security Groups
 |
 +--> ALB
 |      |
 |      +--> Target Group
 |      |
 |      +--> Listener
 |
 +--> Launch Template
 |
 +--> Auto Scaling Group
        |
        +--> EC2 Instances
```

---

# Validation and Testing

After deployment, the infrastructure can be tested through the ALB DNS endpoint.

Example:

```bash
curl http://<ALB-DNS-NAME>
```

Repeated requests can be used to verify that traffic is being distributed across instances.

The response should contain instance-specific information such as:

```text
Instance ID
Hostname
Availability Zone
Private IP
```

This allows the load-balancing behavior to be observed.

---

# High Availability

The infrastructure uses multiple Availability Zones.

Instead of relying on a single EC2 instance:

```text
        EC2
         |
       Failure
         |
      OUTAGE
```

the architecture uses:

```text
          ALB
           |
      +----+----+
      |         |
     EC2       EC2
     AZ-A      AZ-B
```

If an individual instance becomes unhealthy, the ALB can stop sending traffic to it and the Auto Scaling Group can replace it.

---

# Scalability

The infrastructure is designed to scale horizontally.

Initial state:

```text
2 EC2 instances
```

Under increased CPU utilization:

```text
2 → 3 → 4
```

When demand decreases:

```text
4 → 3 → 2
```

The infrastructure therefore avoids relying on vertical scaling of a single server.

---

# Infrastructure as Code Benefits

Using Terraform provides several advantages over manual AWS configuration:

* Repeatable deployments
* Version-controlled infrastructure
* Consistent environments
* Automated dependency management
* Easier disaster recovery
* Code review capability
* Reduced configuration drift
* Reusable modules

The infrastructure configuration can be reviewed alongside application code in Git.

---

# Technologies Used

| Technology                    | Purpose                         |
| ----------------------------- | ------------------------------- |
| AWS VPC                       | Network isolation               |
| AWS EC2                       | Compute                         |
| AWS Launch Template           | EC2 configuration               |
| AWS Application Load Balancer | Traffic distribution            |
| AWS Target Groups             | Backend registration            |
| AWS Auto Scaling              | Horizontal scaling              |
| AWS CloudWatch                | Monitoring and scaling triggers |
| AWS IAM                       | Access control                  |
| Terraform                     | Infrastructure as Code          |
| Amazon Linux 2023             | Operating system                |
| Git/GitHub                    | Version control                 |

---

# Engineering Decisions

### Dynamic AMI discovery

Rather than hardcoding an AMI ID, Terraform retrieves the latest matching Amazon Linux 2023 AMI.

### Multi-AZ deployment

The infrastructure spans multiple Availability Zones to improve availability.

### Modular Terraform

Terraform modules separate networking, security, IAM, load balancing, launch configuration, and scaling responsibilities.

### Load balancer health checks

Traffic is sent to healthy instances rather than simply checking whether an EC2 instance is running.

### Automated instance configuration

User data removes the need for manual server configuration after launch.

### Infrastructure version control

The complete infrastructure is represented as code and stored in Git.

---

# Project Status

Current implementation includes:

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
* [ ] Resolve AWS Auto Scaling service-linked-role deployment issue
* [ ] Deploy EC2 instances successfully
* [ ] Validate ALB traffic distribution
* [ ] Test automatic scale-out
* [ ] Test automatic scale-in
* [ ] Add final deployment screenshots
* [ ] Document operational testing

---

# Lessons Demonstrated

This project demonstrates practical experience with:

1. Designing AWS infrastructure
2. Building infrastructure using Terraform
3. Working with Terraform modules
4. Managing resource dependencies
5. Dynamic AWS resource discovery
6. Designing highly available infrastructure
7. Implementing load balancing
8. Implementing horizontal scaling
9. Using IAM securely
10. Monitoring infrastructure with CloudWatch
11. Debugging Terraform/AWS deployment failures
12. Using Git for infrastructure version control

---

# Future Improvements

Potential production improvements include:

* Private subnets for EC2 instances
* NAT Gateway architecture
* HTTPS using ACM certificates
* Route 53 DNS
* AWS WAF
* SSM Session Manager
* Remote Terraform state using S3
* DynamoDB state locking
* CI/CD pipeline for Terraform
* Separate development/staging/production environments
* Terraform testing
* CloudWatch dashboards
* Centralized logging
* More advanced target-tracking scaling policies

---

# Disclaimer

This project is designed as a cloud engineering portfolio project and learning environment.

Before using a similar architecture in production, additional security, networking, monitoring, cost-control, compliance, and operational requirements should be evaluated.

````

## One important change I'd make to the README

Because we **haven't successfully completed the ASG deployment yet**, I deliberately marked it:

```text
[ ] Resolve AWS Auto Scaling service-linked-role deployment issue
````

rather than pretending the entire system is operational.

That's actually valuable from a recruiter perspective. Once we fix the IAM/service-linked-role issue and verify the instances and ALB, we'll change those items to `[x]` and add real screenshots/results.

### For the diagram

I recommend we create a **custom architecture diagram specifically for your implementation**, rather than using a generic AWS diagram. It should show:

```text
                    INTERNET
                       |
                       v
              ┌─────────────────┐
              │ Application     │
              │ Load Balancer   │
              └────────┬────────┘
                       |
                 Target Group
                       |
          ┌────────────┴────────────┐
          │                         │
     Public Subnet A           Public Subnet B
       us-east-1a                us-east-1b
          │                         │
       EC2 #1                    EC2 #2
          │                         │
          └────────────┬────────────┘
                       │
                Auto Scaling Group
                  min 2 / max 4
                       │
              CloudWatch Alarms
                 ↙           ↘
            CPU > 70%     CPU < 30%
              Scale Out     Scale In
```

And around those components we'll show the **VPC, Internet Gateway, Security Groups, IAM, Launch Template, and Terraform** relationships.

If you want, I can generate that **actual architecture diagram as an image** now, ready to put into your repository.
