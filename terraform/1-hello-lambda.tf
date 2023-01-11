# Workflow for Terraform when using `ZIP Archive File` data source:

# 1. Function is built
# 2. We package the Function (and all its dependencies) into a ZIP file
# 3. ZIP file is uploaded into S3
# 4. Within Terraform, when we create a Lambda function, we point to the S3 bucket ZIP archive

resource "aws_iam_role" "hello_lambda_exec" {
  name = "hello-lambda"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "hello_lambda_policy" {
  role       = aws_iam_role.hello_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello" {
  function_name = "hello"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_hello.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.lambda_hello.output_base64sha256

  role = aws_iam_role.hello_lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "hello" {
  name = "/aws/lambda/${aws_lambda_function.hello.function_name}"

  # more/less days affects cost on infrastructure
  retention_in_days = 14
}

# this section generates a file:
# for `local` development & testing  (OK)
# Alternative: for `production` we should build a CI/CD pipeline that works without needing this resource
data "archive_file" "lambda_hello" {
  type = "zip"

  source_dir  = "${path.module}/hello"
  output_path = "${path.module}/hello.zip"
}

# Alternative: ideally this should be part of the CI/CD pipeline
resource "aws_s3_object" "lambda_hello" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "hello.zip"
  source = data.archive_file.lambda_hello.output_path

  # `etag` triggers updates whenever associated value changes
  etag = filemd5(data.archive_file.lambda_hello.output_path)
  # caveat: for objects bigger than 16 MB this approach might not work
}
