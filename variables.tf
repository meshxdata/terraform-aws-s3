variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket. Must be globally unique."
}

variable "versioning" {
  type        = bool
  description = "Whether to enable object versioning on the bucket."
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of a customer managed KMS key for default encryption. If null, the AWS managed key (aws/s3) is used."
  default     = null
}

variable "deny_insecure_transport" {
  type        = bool
  description = "Attach a bucket policy that denies any request not made over TLS."
  default     = true
}

variable "logging_target_bucket" {
  type        = string
  description = "Name of the bucket that receives server access logs. If null, access logging is disabled."
  default     = null
}

variable "logging_target_prefix" {
  type        = string
  description = "Prefix for server access log objects written to the target bucket."
  default     = ""
}

variable "lifecycle_rules" {
  type = list(object({
    id                         = string
    enabled                    = optional(bool, true)
    prefix                     = optional(string, "")
    expiration_days            = optional(number)
    noncurrent_expiration_days = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
  }))
  description = "Lifecycle rules to apply to the bucket. Noncurrent-version expiration only takes effect when versioning is enabled."
  default     = []

  validation {
    condition     = alltrue([for r in var.lifecycle_rules : r.expiration_days != null || r.noncurrent_expiration_days != null || length(r.transitions) > 0])
    error_message = "Each lifecycle rule must define at least one transition, expiration_days, or noncurrent_expiration_days."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the bucket."
  default     = {}
}

variable "abort_incomplete_multipart_days" {
  type        = number
  description = "Days after which incomplete multipart uploads are aborted."
  default     = 7
}
