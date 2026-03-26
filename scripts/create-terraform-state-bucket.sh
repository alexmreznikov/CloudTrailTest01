#!/bin/bash
set -e

# Script to create an S3 bucket for Terraform remote state storage
# with security best practices (encryption, versioning, public access block)

# Configuration
BUCKET_NAME="${TF_STATE_BUCKET:-org-mgmt-terraform-state-alexorg-local}"
REGION="${AWS_REGION:-ap-southeast-2}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Terraform State Bucket Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${BLUE}Configuration:${NC}"
echo "  Bucket Name:     $BUCKET_NAME"
echo "  Region:          $REGION"
echo ""

# Check if bucket already exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Bucket '$BUCKET_NAME' already exists${NC}"
    echo ""
    read -p "Do you want to update its configuration? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping bucket creation"
        SKIP_BUCKET=true
    fi
fi

if [ "$SKIP_BUCKET" != "true" ]; then
    echo -e "${BLUE}Creating S3 bucket...${NC}"

    # Create the bucket
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION" \
        2>/dev/null || echo "Bucket may already exist, continuing..."

    echo -e "${GREEN}✓ Bucket created${NC}"

    # Enable versioning
    echo -e "${BLUE}Enabling versioning...${NC}"
    aws s3api put-bucket-versioning \
        --bucket "$BUCKET_NAME" \
        --versioning-configuration Status=Enabled
    echo -e "${GREEN}✓ Versioning enabled${NC}"

    # Enable server-side encryption
    echo -e "${BLUE}Enabling server-side encryption...${NC}"
    aws s3api put-bucket-encryption \
        --bucket "$BUCKET_NAME" \
        --server-side-encryption-configuration '{
            "Rules": [{
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                },
                "BucketKeyEnabled": true
            }]
        }'
    echo -e "${GREEN}✓ Encryption enabled${NC}"

    # Block public access
    echo -e "${BLUE}Blocking public access...${NC}"
    aws s3api put-public-access-block \
        --bucket "$BUCKET_NAME" \
        --public-access-block-configuration \
            BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
    echo -e "${GREEN}✓ Public access blocked${NC}"

    # Add bucket policy to enforce encryption
    echo -e "${BLUE}Adding bucket policy...${NC}"
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    aws s3api put-bucket-policy \
        --bucket "$BUCKET_NAME" \
        --policy "{
            \"Version\": \"2012-10-17\",
            \"Statement\": [
                {
                    \"Sid\": \"DenyUnencryptedObjectUploads\",
                    \"Effect\": \"Deny\",
                    \"Principal\": \"*\",
                    \"Action\": \"s3:PutObject\",
                    \"Resource\": \"arn:aws:s3:::$BUCKET_NAME/*\",
                    \"Condition\": {
                        \"StringNotEquals\": {
                            \"s3:x-amz-server-side-encryption\": \"AES256\"
                        }
                    }
                }
            ]
        }"
    echo -e "${GREEN}✓ Bucket policy applied${NC}"

    # Add tags
    echo -e "${BLUE}Adding tags...${NC}"
    aws s3api put-bucket-tagging \
        --bucket "$BUCKET_NAME" \
        --tagging "TagSet=[
            {Key=Purpose,Value=TerraformState},
            {Key=ManagedBy,Value=Script},
            {Key=is-guardrail,Value=true}
        ]"
    echo -e "${GREEN}✓ Tags added${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Backend Configuration:${NC}"
echo ""
echo "Add this to your Terraform configuration (backend.tf):"
echo ""
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"$BUCKET_NAME\""
echo "    key            = \"terraform.tfstate\""
echo "    region         = \"$REGION\""
echo "    encrypt        = true"
echo "  }"
echo "}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Add the backend configuration to your Terraform code"
echo "2. Run: terraform init -reconfigure"
echo "3. Run: ./scripts/terraform-apply.sh"
echo ""
