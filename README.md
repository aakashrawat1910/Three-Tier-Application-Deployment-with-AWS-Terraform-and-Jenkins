# Three-Tier Application Deployment with AWS, Terraform, and Jenkins

## Project Overview

This project implements a complete DevOps solution for deploying a three-tier web application (React frontend, Node.js backend, MongoDB database) on AWS infrastructure. The solution uses Infrastructure as Code (IaC) with Terraform for provisioning AWS resources and Jenkins for CI/CD pipeline automation.

## Architecture

The architecture consists of:

1. **Frontend Tier**: React.js application hosted on an EC2 instance with an Application Load Balancer
2. **Backend Tier**: Node.js REST API service hosted on a separate EC2 instance
3. **Database Tier**: MongoDB database hosted on a dedicated EC2 instance

All components are deployed in the default VPC with proper security groups to ensure network isolation between tiers.

## Directory Structure

```
three-tier-app-deployment/
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   ├── compute.tf              # EC2 instances, load balancers
│   ├── security.tf             # Security groups
│   ├── scripts/                # Scripts for instance configuration
│   │   ├── mongodb_setup.sh    # MongoDB setup script
│   │   ├── backend_setup.sh    # Backend setup script
│   │   └── frontend_setup.sh   # Frontend setup script
│   └── terraform.tfvars        # Variable values (not committed to repo)
│
├── jenkins/
│   └── Jenkinsfile             # Jenkins pipeline definition
│
└── README.md                   # Project documentation
```

## Implementation Details

### Infrastructure as Code (Terraform)

The Terraform configuration is organized into multiple files for better maintainability:

- **main.tf**: Defines the AWS provider and data sources for VPC and subnets
- **variables.tf**: Declares all variables used in the configuration
- **outputs.tf**: Defines output values such as instance IPs and URLs
- **compute.tf**: Configures EC2 instances and load balancer
- **security.tf**: Sets up security groups for proper network isolation

### Server Configuration

Instance configuration is handled through user data scripts:

- **mongodb_setup.sh**: Installs and configures MongoDB
- **backend_setup.sh**: Sets up Node.js, clones the repository, and configures environment variables
- **frontend_setup.sh**: Installs Node.js, builds the React application, and configures it to connect to the backend

### CI/CD Pipeline (Jenkins)

The Jenkins pipeline is defined in the Jenkinsfile with the following stages:

1. **Checkout**: Retrieves the code from the repository
2. **Validate Infrastructure**: Initializes Terraform and validates the configuration
3. **Deploy Infrastructure**: Applies the Terraform configuration to provision resources
4. **Test Backend**: Verifies that the backend API is accessible
5. **Test Frontend**: Ensures the frontend application is working
6. **Security Scan**: Performs security checks on the infrastructure

## Security Considerations

- Security groups are configured to restrict access between tiers
- Sensitive information is stored in AWS Parameter Store
- SSH access is limited (should be further restricted in production)
- Network isolation is implemented between application tiers

## Deployment Instructions

### Prerequisites

- AWS account with appropriate permissions
- Terraform installed (v1.0.0 or later)
- Jenkins server with AWS and Terraform plugins
- SSH key pair for EC2 instances

### Manual Deployment

1. Clone the repository
2. Navigate to the terraform directory
3. Create a `terraform.tfvars` file with your specific values
4. Initialize Terraform: `terraform init`
5. Plan the deployment: `terraform plan -out=tfplan`
6. Apply the configuration: `terraform apply tfplan`

### Automated Deployment with Jenkins

1. Set up a Jenkins server with necessary plugins
2. Configure AWS credentials in Jenkins
3. Create a new pipeline job pointing to the repository
4. Run the pipeline

## Accessing the Application

After successful deployment, the application can be accessed at:

- Frontend: http://[load-balancer-dns] or http://[frontend-public-ip]:3000
- Backend API: http://[backend-public-ip]:3001

## Cleanup

To destroy the infrastructure:

```bash
cd terraform
terraform destroy -auto-approve
```

## Future Improvements

- Implement auto-scaling for the frontend and backend tiers
- Add HTTPS support with AWS Certificate Manager
- Implement database backups and replication
- Enhance security with more restrictive security groups
- Add monitoring and alerting with CloudWatch

## Assumptions and Decisions

- Used the default VPC for simplicity, but in a production environment, a custom VPC would be preferred
- Stored MongoDB credentials in plaintext for demonstration; in production, use AWS Secrets Manager
- Used t2.micro instances for cost-effectiveness; adjust based on workload requirements
- Frontend and backend are deployed as systemd services for automatic restart