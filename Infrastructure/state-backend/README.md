# Terraform State Backend Setup

This directory contains the infrastructure needed to bootstrap remote state storage for Terraform with DynamoDB state locking.

## Overview

This creates:
- **S3 Bucket**: For storing Terraform state files securely with versioning and encryption
- **DynamoDB Table**: For state locking to prevent concurrent modifications

## Prerequisites

1. AWS CLI configured with appropriate credentials
2. Terraform installed (v0.13 or later)
3. Proper IAM permissions to create S3 buckets and DynamoDB tables

## Setup Instructions

### Step 1: Deploy State Backend Infrastructure

Navigate to the state-backend directory:
```bash
cd Infrastructure/state-backend/
```

Initialize Terraform:
```bash
terraform init
```

Plan the deployment:
```bash
terraform plan -var aws_profile="your-profile" -var aws_region="your-region" -var environment_name="your-env"
```

Deploy the infrastructure:
```bash
terraform apply -var aws_profile="your-profile" -var aws_region="your-region" -var environment_name="your-env"
```

### Step 2: Note the Outputs

After deployment, Terraform will output:
- `s3_bucket_name`: The name of the created S3 bucket
- `dynamodb_table_name`: The name of the created DynamoDB table
- `backend_configuration`: A ready-to-use backend configuration block

### Step 3: Configure Main Infrastructure

1. Go back to the main Infrastructure directory:
   ```bash
   cd ../
   ```

2. Copy the backend configuration template:
   ```bash
   cp backend.tf.example backend.tf
   ```

3. Edit `backend.tf` and replace the placeholder values with the actual values from Step 2

4. Initialize Terraform to migrate to remote state:
   ```bash
   terraform init
   ```

5. When prompted, type `yes` to migrate your existing state to the remote backend

## Important Notes

- **State Security**: The S3 bucket is configured with encryption, versioning, and public access blocking
- **State Locking**: The DynamoDB table prevents concurrent state modifications
- **Backup**: Keep a backup of your local state file before migrating to remote state
- **Cleanup**: If you need to destroy this infrastructure, first ensure no other Terraform configurations are using it

## Resources Created

### S3 Bucket Features:
- Server-side encryption (AES256)
- Versioning enabled
- Public access blocked
- Force destroy protection

### DynamoDB Table Features:
- Pay-per-request billing
- Hash key: `LockID` (String)
- Optimized for state locking operations

## Troubleshooting

- If you get bucket name conflicts, the random suffix should prevent this
- Ensure your AWS credentials have sufficient permissions
- If state migration fails, you can manually specify the backend configuration during `terraform init` 