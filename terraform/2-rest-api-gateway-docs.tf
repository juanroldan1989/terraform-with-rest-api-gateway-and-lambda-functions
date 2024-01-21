data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:*"
    ]
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${random_pet.docs_api_v1_bucket_name.id}",
      "arn:aws:s3:::${random_pet.docs_api_v1_bucket_name.id}/*"
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    effect = "Allow"
    sid    = "PublicReadGetObject"
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${random_pet.docs_api_v1_bucket_name.id}/*"
    ]
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "random_pet" "docs_api_v1_bucket_name" {
  prefix = "docs-api-v1"
  length = 2
}

resource "aws_s3_bucket" "docs_api_v1" {
  bucket        = random_pet.docs_api_v1_bucket_name.id
  force_destroy = true
}

resource "aws_s3_bucket_policy" "docs_api_v1" {
  bucket = aws_s3_bucket.docs_api_v1.id
  policy = data.aws_iam_policy_document.website_policy.json
}

resource "aws_s3_bucket_acl" "docs_api_v1" {
  bucket     = aws_s3_bucket.docs_api_v1.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.docs_api_v1.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.docs_api_v1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "docs_api_v1" {
  bucket = aws_s3_bucket.docs_api_v1.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "docs_api_v1" {
  bucket = aws_s3_bucket.docs_api_v1.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_object" "docs_api_v1_index_html" {
  bucket = aws_s3_bucket.docs_api_v1.id

  key    = "index.html"
  source = "${path.module}/docs/api/v1/index.html"
}

resource "aws_s3_object" "docs_api_v1_main_json" {
  bucket = aws_s3_bucket.docs_api_v1.id

  key    = "main.json"
  source = "${path.module}/docs/api/v1/main.json"
}

resource "aws_s3_bucket_website_configuration" "docs_api_v1_website" {
  bucket = aws_s3_bucket.docs_api_v1.id

  index_document {
    suffix = "index.html"
  }
}
