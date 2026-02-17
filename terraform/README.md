# Terraform – Infrastructure as Code

This directory defines the AWS infrastructure required to run the Solace event-driven platform.

## Design
- Modular Terraform layout
- Remote state with locking (S3 + DynamoDB)
- Environment separation via tfvars
- EKS-ready architecture

## Note
This project is designed for interview and portfolio demonstration.
Infrastructure is **not applied** to avoid unnecessary AWS costs.

