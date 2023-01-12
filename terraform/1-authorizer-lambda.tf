resource "aws_iam_role" "authorizer_lambda_exec" {
  name = "authorizer-lambda"

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

resource "aws_iam_role_policy_attachment" "authorizer_lambda_policy" {
  role       = aws_iam_role.authorizer_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "authorizer" {
  function_name = "authorizer"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_authorizer.key

  runtime = "nodejs16.x"
  handler = "function.handler"

  source_code_hash = data.archive_file.lambda_authorizer.output_base64sha256

  role = aws_iam_role.authorizer_lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "authorizer" {
  name = "/aws/lambda/${aws_lambda_function.authorizer.function_name}"

  retention_in_days = 14
}

data "archive_file" "lambda_authorizer" {
  type = "zip"

  source_dir  = "${path.module}/authorizer"
  output_path = "${path.module}/authorizer.zip"
}

resource "aws_s3_object" "lambda_authorizer" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "authorizer.zip"
  source = data.archive_file.lambda_authorizer.output_path

  etag = filemd5(data.archive_file.lambda_authorizer.output_path)
}
