# Terraform Cloud Setup Guide

This guide walks you through setting up Terraform Cloud to use this GitHub repository as the source of truth.

## Prerequisites

- Terraform Cloud account (free tier available)
- GitHub repository: `https://github.com/Mattz-CE-ORG/infra`
- AWS credentials

## Step 1: Authenticate with Terraform Cloud

```bash
terraform login
```

This will open your browser to generate an API token.

## Step 2: Initialize Terraform

```bash
terraform init
```

This creates/connects to the workspace `infra` in the `Ars-Org` organization.

## Step 3: Connect GitHub Repository (VCS Integration)

1. **Go to Terraform Cloud:**
   - Navigate to: `https://app.terraform.io/app/Ars-Org/workspaces/infra`

2. **Connect VCS Provider:**
   - Go to **Settings** → **Version Control**
   - If not connected, click **Connect a VCS provider**
   - Select **GitHub** and authorize Terraform Cloud
   - Grant access to the `Mattz-CE-ORG` organization

3. **Configure Repository:**
   - Repository: `Mattz-CE-ORG/infra`
   - Branch: `master`
   - Working Directory: `/` (root)
   - VCS branch tags: Leave default

4. **Save Configuration**

## Step 4: Configure Workspace Settings

1. **Execution Mode:**
   - Go to **Settings** → **General Settings**
   - **Execution Mode**: Choose:
     - **Remote** (recommended): Runs execute in Terraform Cloud
     - **Local**: Runs execute on your machine

2. **Auto Apply:**
   - Go to **Settings** → **General Settings**
   - **Auto Apply**: 
     - Enable for automatic applies (use with caution)
     - Disable for manual approval (recommended for production)

3. **Run Triggers:**
   - Go to **Settings** → **Version Control**
   - **Trigger runs on**: 
     - ✅ Push to default branch (master)
     - ✅ Pull request comments (optional)
     - ✅ Pull request events (optional)

## Step 5: Configure Variables

1. **Go to Variables Tab:**
   - Navigate to **Variables** in your workspace

2. **Add AWS Credentials (Sensitive):**
   - Click **+ Add variable**
   - **Key**: `AWS_ACCESS_KEY_ID`
   - **Value**: Your AWS access key
   - ✅ Mark as **Sensitive**
   - ✅ Mark as **Environment variable**
   - **Category**: Environment variable
   - Save

   - **Key**: `AWS_SECRET_ACCESS_KEY`
   - **Value**: Your AWS secret key
   - ✅ Mark as **Sensitive**
   - ✅ Mark as **Environment variable**
   - **Category**: Environment variable
   - Save

3. **Add Terraform Variables:**
   - **Key**: `aws_region`
   - **Value**: `us-east-1` (or your preferred region)
   - **Category**: Terraform variable
   - Save

## Step 6: Test the Setup

1. **Make a small change** to any `.tf` file
2. **Commit and push:**
   ```bash
   git add .
   git commit -m "Test: Terraform Cloud integration"
   git push origin master
   ```
3. **Check Terraform Cloud:**
   - Go to your workspace
   - You should see a new run triggered automatically
   - Review the plan and approve/apply

## Workflow

### With VCS Integration (Recommended)

1. **Make changes** to Terraform files in this repo
2. **Commit and push** to `master` branch
3. **Terraform Cloud automatically triggers** a plan
4. **Review and approve** in Terraform Cloud UI
5. **Apply** (manual or auto, depending on settings)

### Local Development

1. **Make changes** locally
2. **Run locally:**
   ```bash
   terraform plan   # Preview changes
   terraform apply  # Apply changes
   ```
3. **Or push to trigger** remote run in Terraform Cloud

## Benefits

✅ **Repository as Source of Truth**: All changes go through GitHub  
✅ **Automatic Runs**: Plans triggered on git push  
✅ **State Management**: Secure, encrypted remote state  
✅ **Team Collaboration**: Shared workspace with audit trail  
✅ **Version History**: Track all infrastructure changes  
✅ **State Locking**: Prevents concurrent modification conflicts  

## Troubleshooting

- **Runs not triggering**: Check VCS connection in workspace settings
- **Authentication errors**: Run `terraform login` again
- **Variable not found**: Ensure variables are set in Terraform Cloud workspace
- **State locked**: Another run is in progress, wait for it to complete

