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

variable "read_principals" {
  description = "Principal allowed to read from the bucket (default: current account)"
  type        = list(string)
  default     = []
}

variable "read_tags" {
  description = "Tags required on principals reading to the bucket"
  type        = map(string)
  default     = {}
}

variable "readwrite_principals" {
  description = "Principal allowed to read and write to the bucket (default: current account)"
  type        = list(string)
  default     = []
}

variable "readwrite_tags" {
  description = "Tags required on principals writing to the bucket"
  type        = map(string)
  default     = {}
}
