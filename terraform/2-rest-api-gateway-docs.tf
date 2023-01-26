data "aws_iam_policy_document" "website_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${random_pet.docs_api_v1_bucket_name.id}/*"
    ]
  }
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
  bucket = aws_s3_bucket.docs_api_v1.id
  acl    = "public-read"
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
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
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
