output "policy_json" {
  description = "Required IAM policies"
  value       = data.aws_iam_policy_document.this.json
}

output "name" {
  description = "Name of the created bucket"
  value       = aws_s3_bucket.this.bucket
}
