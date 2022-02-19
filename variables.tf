variable "bucket_policy" {
  description = "Override the resource policy on the bucket"
  type        = string
  default     = null
}

variable "name" {
  type        = string
  description = "The name of the s3 bucket"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to created resources"
  default     = {}
}

variable "trust_principal" {
  description = "Principal allowed to access the secret (default: current account)"
  type        = string
  default     = null
}

variable "trust_tags" {
  description = "Tags required on principals accessing the secret"
  type        = map(string)
  default     = {}
}
