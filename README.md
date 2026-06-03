# Production-Style 3-Tier Dockerized Application on AWS

> A full-stack application deployed on AWS using a secure, scalable, production-style 3-tier architecture with Docker, EC2 Auto Scaling Groups, Public and Internal Application Load Balancers, Amazon RDS MySQL, Amazon ECR, SSM Parameter Store, Route 53, ACM SSL, and GitHub Actions CI/CD.

---

## Project Highlights

This project demonstrates real-world AWS DevOps and Solutions Architect skills by deploying a full-stack application with:

- Dockerized React + Node.js application
- Public frontend entry through an internet-facing Application Load Balancer
- Private backend routing through an internal Application Load Balancer
- EC2 Auto Scaling Groups for frontend and backend compute layers
- Amazon RDS MySQL deployed in private database subnets
- Secrets managed securely with AWS SSM Parameter Store
- Docker images stored in Amazon ECR
- GitHub Actions CI/CD using OIDC instead of long-term AWS access keys
- Independent frontend/backend deployment based on changed files
- HTTPS enabled with ACM and Route 53
- Self-healing infrastructure with ALB health checks and ASG instance refresh

---

## Live Demo

| Resource              | URL                                         |
| --------------------- | ------------------------------------------- |
| Application           | `https://docker.rifkhan.xyz.com`            |
| API Health Check      | `https://docker.rifkhan.xyz.com/api/health` |
| Frontend Health Check | `https://docker.rifkhan.xyz.com/health`     |

---

## Project Overview

This is a full-stack application built with React, Node.js, Express, and MySQL. The main goal of this project is to demonstrate how a real application can be containerized and deployed to AWS using a secure 3-tier cloud architecture.

The application includes:

- User authentication with JWT
- Categories
- Comments
- Admin/author role-based access
- React + Vite frontend
- Node.js + Express backend
- MySQL database
- Dockerized frontend and backend services
- GitHub Actions CI/CD pipeline
- AWS production-style deployment

---

## High-Level Architecture

![Diagram](./docs/images/diagram.png)

```mermaid
flowchart TD
    U[User Browser] --> R53[Route 53 Domain]
    R53 --> ACM[ACM SSL / HTTPS]
    ACM --> PALB[Public Application Load Balancer]
    PALB --> FASG[Frontend Auto Scaling Group]
    FASG --> FEC2[Frontend EC2 Instances]
    FEC2 --> FDOCKER[Docker: Nginx + React Static Build]
    FDOCKER --> IALB[Internal Backend Application Load Balancer]
    IALB --> BASG[Backend Auto Scaling Group]
    BASG --> BEC2[Backend EC2 Instances]
    BEC2 --> BDOCKER[Docker: Node.js + Express API]
    BDOCKER --> RDS[(Amazon RDS MySQL)]

    GH[GitHub Actions] --> ECR[Amazon ECR]
    ECR --> FEC2
    ECR --> BEC2
    SSM[SSM Parameter Store] --> BEC2
```

---

## AWS Architecture Flow

```txt
User Browser
  ↓
Route 53 Domain
  ↓
ACM SSL Certificate
  ↓
Public Application Load Balancer
  ↓
Frontend EC2 Auto Scaling Group
  ↓
Frontend Docker Container running Nginx + React
  ↓
Internal Backend Application Load Balancer
  ↓
Backend EC2 Auto Scaling Group
  ↓
Backend Docker Container running Node.js + Express
  ↓
Amazon RDS MySQL in Private DB Subnets
```

---

## CI/CD Flow

```txt
Developer pushes code to GitHub main branch
  ↓
GitHub Actions workflow starts
  ↓
Detects changed folders
  ↓
Builds only changed service Docker image
  ↓
Pushes image to Amazon ECR
  ↓
Starts Auto Scaling Group Instance Refresh
  ↓
New EC2 instances pull latest image from ECR
  ↓
Application Load Balancer health checks validate instances
  ↓
New version goes live
```

---

## Tech Stack

### Frontend

- React.js
- Vite
- Nginx
- Docker

### Backend

- Node.js
- Express.js
- JWT Authentication
- MySQL client
- Docker

### Database

- Amazon RDS MySQL

### DevOps / Cloud

- AWS VPC
- Amazon EC2
- EC2 Auto Scaling Groups
- Launch Templates
- Application Load Balancer
- Internal Application Load Balancer
- Amazon RDS
- Amazon ECR
- AWS SSM Parameter Store
- IAM Roles
- Route 53
- ACM SSL Certificate
- GitHub Actions
- Docker

---

## AWS Services Used

| AWS Service         | Purpose                                            |
| ------------------- | -------------------------------------------------- |
| VPC                 | Custom isolated network for the application        |
| Public Subnets      | Public ALB and NAT Gateway placement               |
| Private App Subnets | Frontend and backend EC2 instances                 |
| Private DB Subnets  | RDS MySQL database placement                       |
| Internet Gateway    | Internet access for public subnets                 |
| NAT Gateway         | Outbound internet access for private EC2 instances |
| Public ALB          | Public entry point for users                       |
| Internal ALB        | Private backend routing layer                      |
| EC2                 | Runs Docker containers                             |
| Auto Scaling Group  | Self-healing and scalable compute layer            |
| Launch Template     | Defines EC2 instance configuration and user data   |
| ECR                 | Stores frontend and backend Docker images          |
| RDS MySQL           | Managed relational database                        |
| SSM Parameter Store | Stores production secrets and environment values   |
| IAM Roles           | Secure access for EC2 and GitHub Actions           |
| Route 53            | DNS and custom domain management                   |
| ACM                 | SSL/TLS certificate for HTTPS                      |
| CloudWatch          | Logs, monitoring, and future alarms                |

---

## Key DevOps Features

- Dockerized full-stack application
- Custom AWS VPC with public, private app, and private DB subnets
- Frontend and backend EC2 instances deployed in private subnets
- Public ALB exposes only the frontend layer
- Internal ALB protects the backend from direct internet access
- RDS MySQL deployed privately with no public access
- Secrets stored in SSM Parameter Store, not in GitHub or Docker images
- IAM roles used instead of hardcoded AWS credentials
- GitHub Actions uses OIDC for secure AWS authentication
- Docker images are pushed to Amazon ECR
- Auto Scaling Groups provide self-healing infrastructure
- ASG Instance Refresh performs rolling container deployments
- CI/CD deploys frontend and backend independently based on changed files
- HTTPS enabled with ACM certificate
- Route 53 domain points to the public ALB
- HTTP traffic redirects to HTTPS

---

## Why This Architecture?

This architecture separates public access, application compute, and database layers.

Only the public Application Load Balancer is exposed to the internet. The frontend and backend EC2 instances run inside private subnets. The backend service is reachable only through an internal Application Load Balancer. The database accepts MySQL traffic only from the backend EC2 security group.

This design reduces the public attack surface and follows a real-world layered AWS architecture commonly used in production environments.

---

## Security Architecture

```txt
Internet
  ↓
Public ALB Security Group
  ↓
Frontend EC2 Security Group
  ↓
Internal Backend ALB Security Group
  ↓
Backend EC2 Security Group
  ↓
RDS Security Group
```

### Security Group Rules

| Layer                | Allowed Inbound Traffic                    |
| -------------------- | ------------------------------------------ |
| Public ALB           | HTTP 80 and HTTPS 443 from internet        |
| Frontend EC2         | HTTP 80 only from Public ALB SG            |
| Internal Backend ALB | HTTP 80 only from Frontend EC2 SG          |
| Backend EC2          | TCP 5000 only from Internal Backend ALB SG |
| RDS MySQL            | TCP 3306 only from Backend EC2 SG          |

### Security Best Practices Implemented

- Backend is not publicly accessible
- RDS database is not publicly accessible
- EC2 instances are placed in private subnets
- No database credentials are stored in GitHub
- No production `.env` file is committed
- SSM Parameter Store is used for secrets
- EC2 instances use IAM roles
- GitHub Actions uses OIDC, not IAM user access keys
- HTTPS is enabled using ACM
- HTTP traffic redirects to HTTPS

---

## CI/CD Pipeline

The CI/CD pipeline is implemented using GitHub Actions.

### Pipeline Features

- Uses GitHub OIDC to assume an AWS IAM role
- Builds Docker images in GitHub Actions
- Pushes images to Amazon ECR
- Tags images with both `latest` and GitHub commit SHA
- Starts ASG Instance Refresh after pushing images
- Deploys frontend and backend independently

### Optimized Deployment Behavior

```txt
Frontend change only:
  → Build frontend image
  → Push frontend image to ECR
  → Refresh frontend ASG only

Backend change only:
  → Build backend image
  → Push backend image to ECR
  → Refresh backend ASG only

Frontend and backend change:
  → Deploy both services
```

---

## Docker Image Strategy

Images are stored in Amazon ECR.

```txt
frontend:latest
frontend:<github-sha>

backend:latest
backend:<github-sha>
```

The EC2 launch templates use user data to pull the latest image from ECR and start the container.

---

## Deployment Strategy

This project uses Auto Scaling Group Instance Refresh for deployment.

When a new image is pushed to ECR, GitHub Actions starts an instance refresh. The Auto Scaling Group gradually replaces old instances with new ones. Each new instance runs user data, pulls the latest Docker image, starts the container, and registers with the ALB target group.

Traffic is sent only to healthy targets after ALB health checks pass.

---

## Environment and Secrets Management

Production secrets are managed using AWS SSM Parameter Store.

```txt
/docker/db/host
/docker/db/port
/docker/db/name
/docker/db/user
/docker/db/password
/docker/jwt/secret
/docker/cors/origin
```

The backend EC2 IAM role has permission to read only the required application parameters:

```txt
/docker/*
```

This keeps secrets outside:

- GitHub source code
- Docker images
- Public documentation
- Frontend application bundle

---

## Folder Structure

```txt
.
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── .dockerignore
│   └── src/
│
├── backend/
│   ├── Dockerfile
│   ├── .dockerignore
│   └── src/
│
├── infra/
│   ├── userdata/
│      ├── frontend-userdata.sh
│      └── backend-userdata.sh
│
│
│
├── docs/
    |____images/
│          |____ app-home.png
│          |____ api-health.png
│          |____ github-actions-success.png
│          |____ frontend-public-alb.png
│          |____ backend-internal-alb.png
│          |____ target-groups-healthy.png
│          |____ ecr-images.png
│          |____ asg-frontend-backend.png
│          |____ rds-private.png
│          |____ ssm-parameters.png
|          |__ _ _ _ _ _ _ _
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── docker-compose.yml
├── .gitignore
└── README.md
└── - - - - - -
```

---

## Production Deployment Summary

### Frontend

- React app is built using Vite
- Static files are served by Nginx inside a Docker container
- Nginx proxies `/api` requests to the internal backend ALB
- Container runs on EC2 instances inside a frontend Auto Scaling Group

### Backend

- Node.js and Express API runs inside a Docker container
- Backend container reads environment values from SSM Parameter Store
- Backend EC2 instances run in private app subnets
- Backend traffic is accepted only from the internal ALB

### Database

- Amazon RDS MySQL is deployed in private DB subnets
- RDS public access is disabled
- MySQL port 3306 is allowed only from the backend EC2 security group

---

## Screenshots Of Project

> Add screenshots inside the `docs/images/` folder using the same filenames below.

### Live Application

![Live Application](./docs/images/docker-frontpage.png)
![Live Application](./docs/images/docker-dashboard.png)
![Live Application](./docs/images/docker-register-page.png)
![Live Application](./docs/images/docker-cat-1.png)

### GitHub Actions CI/CD Detect Frontend Changes

![GitHub Frontend Detection](./docs/images/docker-only-detect-frontend-cicd-1.png)
![GitHub Frontend Detection](./docs/images/docker-only-detect-frontend-cicd.png)

### Amazon ECR Docker Frontend Images

![ECR Images](./docs/images/docker-frontend-image.png)

### Amazon ECR Docker Backend Images

![ECR Images](./docs/images/docker-backend-image.png)

### VPC

![VPC](./docs/images/docker-vpc.png)

### Subnets

![Subnets](./docs/images/docker-subnets.png)

### Public Frontend Application Load Balancer

![Frontend Public ALB](./docs/images/docker-front-alb.png)
![Frontend Public ALB](./docs/images/docker-frontend-alb-1.png)

### Internal Backend Application Load Balancer

![Backend Internal ALB](./docs/images/docker-backend-alb.png)
![Backend Internal ALB](./docs/images/docker-backend-alb-1.png)

### Healthy Target Groups for Frontend

![Target Groups Healthy](./docs/images/docker-frontend-tg.png)

### Healthy Target Groups for Backend

![Target Groups Healthy](./docs/images/docker-backend-tg.png)

### Auto Scaling Groups for Frontend

![Auto Scaling Groups](./docs/images/docker-frontend-asg.png)
![Auto Scaling Groups](./docs/images/docker-frontend-asg-1.png)

### Auto Scaling Groups for Backend

![Auto Scaling Groups](./docs/images/docker-backend-asg.png)
![Auto Scaling Groups](./docs/images/docker-backend-asg-1.png)

### GitHub Actions CI/CD Success for Frontend

![GitHub Frontend Actions](./docs/images/docker-frontend-cicd.png)
![GitHub Frontend Actions](./docs/images/docker-frontend-cicd-1.png)
![GitHub Frontend Actions](./docs/images/docker-frontend-cicd-2.png)
![GitHub Frontend Actions](./docs/images/docker-frontend-cicd-3.png)
![GitHub Frontend Actions](./docs/images/docker-frontend-cicd-4.png)
![GitHub Frontend Actions](./docs/images/docker-frontend-cicd-5.png)
![GitHub Frontend Actions](./docs/images/docker-frontend-cicd-6.png)

### GitHub Actions CI/CD Detect Backend Changes

![GitHub Frontend Detection Files](./docs/images/docker-backend-cicd-detection-files.png)
![GitHub backend Detection](./docs/images/docker-backend-cicd-detection.png)

### GitHub Actions CI/CD Success for Backend

![GitHub Backend Actions](./docs/images/docker-backend-cicd-1.png)
![GitHub Backend Actions](./docs/images/docker-backend-cicd-2.png)
![GitHub Backend Actions](./docs/images/docker-backend-cicd-3.png)
![GitHub Backend Actions](./docs/images/docker-backend-cicd-4.png)
![GitHub Backend Actions](./docs/images/docker-backend-cicd-5.png)
![GitHub Backend Actions](./docs/images/docker-backend-cicd-6.png)
![GitHub Backend Actions](./docs/images/docker-backend-cicd-7.png)

### Private RDS MySQL

![RDS Private](./docs/images/rds.png)

### ACM Certificates

![ACM Certificates](./docs/images/docker-certificates.png)

### Route53

![Route53](./docs/images/docker-route53-record.png)

### SSM Parameter Store

![SSM Parameter Store](./docs/images/docker-parameter.png)

### Security Groups

![Internet ALB Security Group](./docs/images/docker-internet-alb-sg.png)
![Web ALB Security Group](./docs/images/docker-fronend-server-sg.png)
![Internal ALB Security Group](./docs/images/docker-internal-alb-sg.png)
![App ALB Security Group](./docs/images/docker-backend-server-sg.png)
![RDS ALB Security Group](./docs/images/docker-db-sg.png)

### IAM Roles

![frontend Server Role](./docs/images/docker-frontend-ec2-role.png)
![Backend Server Role](./docs/images/docker-backend-ec2-role.png)
![Backend Server SSM Permisson](./docs/images/docker-backend-ec2-ssm-permisssion.png)
![Github Action Deploy Role](./docs/images/docker-github-actions-deploy-role.png)
![Github Action Deploy Role Policy](./docs/images/docker-github-actions-deploy-policy.png)
![Github Action Deploy Role Trust Relationship](./docs/images/docker-github-actions-deploy-role-trust-relation.png)

### IAM Identity Provider

![IAM Identity Provider OIDC](./docs/images/docker-oidc.png)

---

## What Makes This Project Production-Style?

This project is not a simple EC2 deployment. It includes several production-style cloud architecture practices:

1. The backend is not exposed to the internet.
2. The database is not exposed to the internet.
3. EC2 instances run inside private subnets.
4. Public traffic enters only through an Application Load Balancer.
5. Backend traffic goes through an internal Application Load Balancer.
6. Secrets are stored in SSM Parameter Store.
7. GitHub Actions uses OIDC instead of static AWS keys.
8. Auto Scaling Groups provide self-healing compute.
9. ALB health checks validate deployments.
10. CI/CD deploys only the service that changed.
11. HTTPS is configured with ACM.
12. DNS is managed with Route 53.

---

## What I Learned

Through this project, I practiced and implemented:

- Designing a secure AWS 3-tier architecture
- Creating a custom VPC with public, private app, and private DB subnets
- Deploying Docker containers on EC2 using launch templates
- Using Auto Scaling Groups for self-healing infrastructure
- Using public and internal Application Load Balancers
- Keeping backend services private inside the VPC
- Running RDS MySQL without public access
- Managing secrets with SSM Parameter Store
- Using IAM roles with least-privilege permissions
- Building CI/CD pipelines with GitHub Actions
- Using GitHub OIDC instead of long-term AWS keys
- Publishing Docker images to Amazon ECR
- Performing rolling deployments using ASG Instance Refresh
- Configuring HTTPS with ACM and Route 53
- Optimizing CI/CD to deploy frontend/backend independently

---

## Future Improvements

Planned improvements:

- Move frontend static build to S3 and CloudFront
- Add CloudFront caching and AWS WAF
- Add CloudWatch dashboards and alarms
- Add centralized application logs
- Add Terraform version of the infrastructure
- Add CloudFormation version of the infrastructure
- Add ECS Fargate deployment version
- Add ECS EC2 deployment version
- Add serverless version using S3, CloudFront, Lambda, API Gateway, and DynamoDB
- Add automated database migration step in CI/CD
- Add blue/green deployment strategy
- Add image vulnerability scanning and lifecycle cleanup rules in ECR

---

## Project Status

Completed:

- Full-stack Blog CRUD application
- Dockerized frontend and backend
- Local Docker Compose environment
- Amazon ECR image repositories
- Custom AWS VPC and subnet architecture
- Public frontend ALB
- Internal backend ALB
- Frontend Auto Scaling Group
- Backend Auto Scaling Group
- Private RDS MySQL database
- SSM Parameter Store secrets
- Route 53 custom domain
- ACM HTTPS certificate
- GitHub Actions CI/CD
- Independent frontend/backend deployments

Next versions:

- Infrastructure as Code with Terraform
- ECS Fargate version
- Serverless version
- CloudFront + S3 frontend version

---

## Author

**Mohammed Rifkhan**  
Full-Stack Developer | AWS Certified Solutions Architect Associate | DevOps Learner
