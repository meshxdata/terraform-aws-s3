# terraform-aws-s3

Creates an S3 bucket with:

- Versioning (on by default)
- SSE-KMS default encryption with bucket keys. Uses your `kms_key_arn` if set, otherwise the AWS managed key
- All public access blocked
- A bucket policy that denies requests not made over TLS (on by default)
- Optional lifecycle rules
- Optional server access logging

## Usage

```hcl
module "s3" {
  source  = "meshxdata/s3/aws"
  version = "~> 1.0"

  bucket_name = "my-example-bucket"
  kms_key_arn = "arn:aws:kms:eu-west-1:123456789012:key/REPLACE-ME"

  lifecycle_rules = [
    {
      id                         = "expire-old-objects"
      prefix                     = "logs/"
      expiration_days            = 365
      noncurrent_expiration_days = 30
      transitions = [
        { days = 30, storage_class = "STANDARD_IA" },
      ]
    },
  ]

  logging_target_bucket = "my-log-bucket"
  logging_target_prefix = "s3-access/my-example-bucket/"

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket. Must be globally unique. | `string` | n/a | yes |
| versioning | Whether to enable object versioning on the bucket. | `bool` | `true` | no |
| kms_key_arn | ARN of a customer managed KMS key for default encryption. If null, the AWS managed key is used. | `string` | `null` | no |
| deny_insecure_transport | Attach a bucket policy that denies any request not made over TLS. | `bool` | `true` | no |
| logging_target_bucket | Bucket that receives server access logs. If null, access logging is disabled. | `string` | `null` | no |
| logging_target_prefix | Prefix for server access log objects in the target bucket. | `string` | `""` | no |
| lifecycle_rules | Lifecycle rules: `id`, `enabled`, `prefix`, `expiration_days`, `noncurrent_expiration_days`, `transitions`. | `list(object)` | `[]` | no |
| tags | Tags to apply to the bucket. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket. |
| bucket_arn | The ARN of the bucket. |
| bucket_regional_domain_name | The bucket region-specific domain name. |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | ~> 5.0 |
