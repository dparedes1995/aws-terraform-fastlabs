# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-16

### Added
- Initial release of AWS Lambda + Terraform + CloudWatch Logs project
- Lambda function with Node.js 20.x handler
- Structured JSON logging in CloudWatch
- IAM role with least privilege (AWSLambdaBasicExecutionRole)
- Random ID suffix for IAM role names (prevents conflicts)
- Tags for cost tracking and organization (Environment, Project)
- Support for synchronous (RequestResponse) and asynchronous (Event) invocations
- Comprehensive README with educational concepts
- Build script with .env validation
- Load credentials helper script
- Terraform outputs for easy testing
- Examples of CloudWatch Logs queries
- Troubleshooting guide for common errors

### Documentation
- Complete setup instructions for AWS IAM user
- Terraform best practices explanations
- Trust policies vs resource policies concepts
- Managed vs inline policies comparison
- Cold start vs warm start analysis
- Cost estimation and optimization tips

### Infrastructure
- AWS Provider configuration for us-east-1
- Variables for parametrized infrastructure
- Outputs for Lambda ARN, function name, role info, and log group
- .gitignore for sensitive files and artifacts

[1.0.0]: https://github.com/davidparedes/aws-terraform-fastlabs/releases/tag/v1.0.0
