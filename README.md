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

## Terraform Cloud Setup

This repository is configured to use **Terraform Cloud** as the backend. The GitHub repository (`https://github.com/Mattz-CE-ORG/infra`) is the **source of truth** for all infrastructure changes.

### Initial Setup

1. **Authenticate with Terraform Cloud:**
   ```bash
   terraform login
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```
   This will create/connect to the workspace `infra` in the `Ars-Org` organization.

### VCS Integration (Recommended)

To enable automatic runs on git push:

1. **In Terraform Cloud UI:**
   - Go to your workspace: `https://app.terraform.io/app/Ars-Org/workspaces/infra`
   - Navigate to **Settings** → **Version Control**
   - Click **Connect a VCS provider** (if not already connected)
   - Select **GitHub** and authorize Terraform Cloud
   - Choose repository: `Mattz-CE-ORG/infra`
   - Set working directory (if needed)
   - Set branch: `master`

2. **Configure Workspace Settings:**
   - **Execution Mode**: Remote (recommended) or Local
   - **Auto Apply**: Enable if you want automatic applies (or manual approval)
   - **Trigger Runs**: On push to master branch

3. **Set Environment Variables:**
   - Go to **Variables** tab in workspace
   - Add sensitive variables:
     - `AWS_ACCESS_KEY_ID` (mark as sensitive)
     - `AWS_SECRET_ACCESS_KEY` (mark as sensitive)
   - Add Terraform variables:
     - `aws_region` (default: `us-east-1`)

### Workflow

**With VCS Integration (Recommended):**
1. Make changes to Terraform files in this repo
2. Commit and push to `master` branch
3. Terraform Cloud automatically triggers a plan
4. Review and approve/apply in Terraform Cloud UI

**Local Development:**
1. Make changes locally
2. Run `terraform plan` to preview
3. Run `terraform apply` to apply (or push to trigger remote run)

## State Management

State is stored remotely in Terraform Cloud, providing:
- Secure, encrypted state storage
- Automatic state locking
- Version history and audit trail
- Team collaboration features

