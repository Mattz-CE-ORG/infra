# ARS Org - Terraform Infrastructure

This repository contains Terraform configuration for managing AWS infrastructure.

## Prerequisites

- Terraform >= 1.0 installed
- AWS credentials configured via environment variables:
  - `AWS_ACCESS_KEY_ID` (or `AWS_ACCESS_KEY`)
  - `AWS_SECRET_ACCESS_KEY`
- AWS CLI configured (optional but recommended)

## Setup

1. **Configure AWS credentials** (if not already set):
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   ```

2. **Copy example variables file** (optional):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan changes**:
   ```bash
   terraform plan
   ```

5. **Apply changes**:
   ```bash
   terraform apply
   ```

## Configuration

- **AWS Region**: Defaults to `us-east-1`, can be overridden via `aws_region` variable
- **Credentials**: Uses environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
- **Resources**: No resources are created by default. Add your resources to `main.tf` when ready.

## Variables

See `variables.tf` for all available variables. Key variables:
- `aws_region`: AWS region (default: us-east-1)

## Outputs

After applying, view outputs with:
```bash
terraform output
```

## State Management

For production use, configure a remote backend in `main.tf` (currently commented out). Recommended backends:
- S3 with DynamoDB for state locking
- Terraform Cloud

