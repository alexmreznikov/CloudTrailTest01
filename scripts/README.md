# CloudTrail Deployment Scripts

This directory contains bash scripts extracted from the GitHub Actions workflow for better maintainability and reusability.

## Scripts Overview

### Environment and Validation

#### `determine-environment.sh`
Validates that the parameter file exists for the selected environment and sets GitHub environment variables.

**Usage:**
```bash
./determine-environment.sh <environment> <workspace>
```

**Example:**
```bash
./determine-environment.sh prod /Users/user/project
```

#### `validate-template.sh`
Validates the CloudFormation template syntax.

**Usage:**
```bash
./validate-template.sh <workspace> <template_file>
```

**Example:**
```bash
./validate-template.sh . cloudformation/cloudtrail.yaml
```

### Preflight and Deployment

#### `preflight-checks.sh`
Performs preflight checks including caller identity, stack status verification, and parameter validation.

**Usage:**
```bash
./preflight-checks.sh <stack_name> <aws_region> <workspace> <params_file>
```

**Example:**
```bash
./preflight-checks.sh org-mgmt-cloudtrail-stack ap-southeast-2 . vars/prod.json
```

#### `dry-run.sh`
Creates a CloudFormation change set to preview infrastructure changes without applying them.

**Usage:**
```bash
./dry-run.sh <stack_name> <aws_region> <workspace> <template_file> <params_file> <env_key> <change_set_name>
```

**Example:**
```bash
./dry-run.sh org-mgmt-cloudtrail-stack ap-southeast-2 . cloudformation/cloudtrail.yaml vars/prod.json prod dry-run-12345
```

#### `cleanup-changeset.sh`
Deletes a specific CloudFormation change set (used after dry-run).

**Usage:**
```bash
./cleanup-changeset.sh <stack_name> <aws_region> <change_set_name>
```

**Example:**
```bash
./cleanup-changeset.sh org-mgmt-cloudtrail-stack ap-southeast-2 dry-run-12345
```

#### `deploy-stack.sh`
Deploys the CloudFormation stack with the specified parameters and tags.

**Usage:**
```bash
./deploy-stack.sh <stack_name> <aws_region> <workspace> <template_file> <params_file> <env_key>
```

**Example:**
```bash
./deploy-stack.sh org-mgmt-cloudtrail-stack ap-southeast-2 . cloudformation/cloudtrail.yaml vars/prod.json prod
```

### Monitoring and Verification

#### `dump-stack-events.sh`
Displays the latest CloudFormation stack events (useful for debugging failures).

**Usage:**
```bash
./dump-stack-events.sh <stack_name> <aws_region>
```

**Example:**
```bash
./dump-stack-events.sh org-mgmt-cloudtrail-stack ap-southeast-2
```

#### `show-stack-outputs.sh`
Displays the CloudFormation stack outputs.

**Usage:**
```bash
./show-stack-outputs.sh <stack_name> <aws_region>
```

**Example:**
```bash
./show-stack-outputs.sh org-mgmt-cloudtrail-stack ap-southeast-2
```

#### `verify-trail-exists.sh`
Verifies that the CloudTrail trail exists.

**Usage:**
```bash
./verify-trail-exists.sh <trail_name> <aws_region>
```

**Example:**
```bash
./verify-trail-exists.sh org-mgmt-cloudtrail ap-southeast-2
```

#### `verify-trail-logging.sh`
Verifies that the CloudTrail trail is actively logging.

**Usage:**
```bash
./verify-trail-logging.sh <trail_name> <aws_region>
```

**Example:**
```bash
./verify-trail-logging.sh org-mgmt-cloudtrail ap-southeast-2
```

#### `verify-trail-configuration.sh`
Verifies that the CloudTrail trail is configured correctly (multi-region, global events, S3 bucket, log validation).

**Usage:**
```bash
./verify-trail-configuration.sh <trail_name> <aws_region> <expected_s3_bucket>
```

**Example:**
```bash
./verify-trail-configuration.sh org-mgmt-cloudtrail ap-southeast-2 org-mgmt-cloudtrail-logs-alexorg-remote
```

### Cleanup and Destruction

#### `delete-stack.sh`
Deletes the CloudFormation stack and waits for deletion to complete.

**Usage:**
```bash
./delete-stack.sh <stack_name> <aws_region>
```

**Example:**
```bash
./delete-stack.sh org-mgmt-cloudtrail-stack ap-southeast-2
```

#### `cleanup-all.sh`
Performs a complete cleanup by deleting all change sets and the stack.

**Usage:**
```bash
./cleanup-all.sh <stack_name> <aws_region>
```

**Example:**
```bash
./cleanup-all.sh org-mgmt-cloudtrail-stack ap-southeast-2
```

## Common Patterns

All scripts follow these conventions:
- Use `set -euxo pipefail` for strict error handling
- Accept positional parameters for flexibility
- Include usage comments at the top
- Return appropriate exit codes (0 for success, non-zero for failure)
- Use GitHub Actions error formatting when applicable (`::error::`)

## Running Locally

These scripts can be run locally for testing or manual operations. Ensure you have:
1. AWS CLI installed and configured
2. Appropriate AWS credentials set up
3. `jq` installed (required by several scripts)
4. Execute permissions on the scripts (`chmod +x scripts/*.sh`)

## Integration with GitHub Actions

These scripts are called from `.github/workflows/deploy.yml`. The workflow passes GitHub context variables (like `${{ github.workspace }}` and `${{ vars.AWS_REGION }}`) as parameters to the scripts.