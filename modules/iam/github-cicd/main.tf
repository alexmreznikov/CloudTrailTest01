# Already exists for Org Mgmt Account
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = merge(
    {
      "is-guardrail"                       = "true"
      "cmdb-technical-service-offering-id" = var.serviceid
      "Name"                               = "github-oidc-provider"
    },
    var.tags
  )
}

# GitHub OIDC Role
# This role is assumed by GitHub Actions using OIDC authentication
resource "aws_iam_role" "github_oidc" {
  name        = var.oidc_role_name
  description = "Role for GitHub Actions OIDC authentication"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = merge(
    {
      "is-guardrail"                       = "true"
      "cmdb-technical-service-offering-id" = var.serviceid
      "Name"                               = var.oidc_role_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = false
  }
}

# Policy for OIDC role to assume CICD role
resource "aws_iam_role_policy" "oidc_assume_cicd" {
  name = "assume-cicd-role"
  role = aws_iam_role.github_oidc.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AssumeGithubCICDRole"
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Resource = aws_iam_role.github_cicd.arn
      }
    ]
  })
}

# GitHub CICD Role
# This role contains the actual permissions for CloudTrail operations
# It is assumed by the OIDC role (role chaining)
resource "aws_iam_role" "github_cicd" {
  name        = var.cicd_role_name
  description = "Role for GitHub Actions CI/CD with CloudTrail permissions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.github_oidc.arn
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(
    {
      "is-guardrail"                       = "true"
      "cmdb-technical-service-offering-id" = var.serviceid
      "Name"                               = var.cicd_role_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = false
  }
}

# CloudTrail permissions policy for CICD role
resource "aws_iam_role_policy" "cicd_cloudtrail" {
  name = "cloudtrail-management"
  role = aws_iam_role.github_cicd.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudTrailManagement"
        Effect = "Allow"
        Action = [
          "cloudtrail:CreateTrail",
          "cloudtrail:UpdateTrail",
          "cloudtrail:StartLogging",
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:PutEventSelectors",
          "cloudtrail:PutInsightSelectors",
          "cloudtrail:AddTags",
          "cloudtrail:RemoveTags",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "cloudtrail:GetEventSelectors",
          "cloudtrail:GetInsightSelectors",
          "cloudtrail:ListTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "TerraformStateS3Bucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning"
        ]
        Resource = var.terraform_state_bucket_arn
      },
      {
        Sid    = "TerraformStateS3Objects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${var.terraform_state_bucket_arn}/*"
      },
      {
        Sid    = "S3PermissionsForCloudTrail"
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogsForCloudTrail"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPermissionsForCloudTrailRole"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:PassRole",
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
      }
    ]
  })
}
