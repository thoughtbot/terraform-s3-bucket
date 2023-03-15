resource "aws_s3_bucket" "this" {
  bucket = var.name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this.id
      sse_algorithm     = "aws:kms"
    }
  }
}

data "aws_iam_policy_document" "bucket" {
  override_policy_documents = compact([var.bucket_policy])

  statement {
    sid       = "AllowManagement"
    resources = [local.bucket_arn, "${local.bucket_arn}/*"]
    not_actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    principals {
      type        = "AWS"
      identifiers = [local.account_arn]
    }
  }

  statement {
    sid       = "AllowWrite"
    resources = [local.bucket_arn, "${local.bucket_arn}/*"]
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    principals {
      type        = "AWS"
      identifiers = local.readwrite_principals
    }
    dynamic "condition" {
      for_each = var.readwrite_tags

      content {
        test     = "StringEquals"
        variable = "aws:PrincipalTag/${condition.key}"
        values   = [condition.value]
      }
    }
  }

  statement {
    sid       = "AllowRead"
    resources = [local.bucket_arn, "${local.bucket_arn}/*"]
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    principals {
      type        = "AWS"
      identifiers = local.read_principals
    }
    dynamic "condition" {
      for_each = var.read_tags

      content {
        test     = "StringEquals"
        variable = "aws:PrincipalTag/${condition.key}"
        values   = [condition.value]
      }
    }
  }

  statement {
    sid       = "RequireObjectEncryption"
    effect    = "Deny"
    actions   = ["s3:PutObject"]
    resources = ["${local.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [aws_kms_key.this.arn]
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "this" {
  statement {
    sid = "ReadWrite${local.sid_suffix}"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*",
    ]
  }

  statement {
    sid = "List${local.sid_suffix}"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.this.arn
    ]
  }

  statement {
    sid = "Decrypt${local.sid_suffix}"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = [
      aws_kms_key.this.arn
    ]
  }
}

resource "aws_kms_key" "this" {
  description         = "Key for bucket ${var.name}"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.key.json
  tags                = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/s3/${var.name}"
  target_key_id = aws_kms_key.this.arn
}

data "aws_iam_policy_document" "key" {
  statement {
    sid = "AllowManagement"
    not_actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    principals {
      identifiers = [local.account_arn]
      type        = "AWS"
    }
  }

  statement {
    sid = "AllowS3"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    principals {
      identifiers = [local.account_arn]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["s3.${local.region}.amazonaws.com"]
    }
  }

  statement {
    sid    = "DenyDirectDecryption"
    effect = "Deny"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    condition {
      test     = "StringNotEquals"
      variable = "kms:ViaService"
      values   = ["s3.${local.region}.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

locals {
  account_arn          = "arn:aws:iam::${local.account_id}:root"
  account_id           = data.aws_caller_identity.this.account_id
  bucket_arn           = "arn:aws:s3:::${var.name}"
  region               = data.aws_region.this.name
  sid_suffix           = join("", regexall("[[:alnum:]]+", var.name))
  read_principals      = concat(var.read_principals, local.readwrite_principals)
  readwrite_principals = coalescelist(var.readwrite_principals, [local.account_arn])
}
