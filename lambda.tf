data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "." # Directory containing the Lambda function code, here it is the current directory
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "j09_lambda"
  role = aws_iam_role.lambda_role.arn
  handler          = "main.handler"
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 128
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256 

    environment {
        variables = {
          "BUCKET_PATH" = "bucket-store-j09/uploads/"
        }
    }
}

resource "aws_iam_role" "lambda_role" {
  name = "j09_lambda_role"
  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_policy" "s3_bucket_policy" {
    name        = "s3-bucket-policy"
    description = "Allows read and write access to S3 buckets"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::bucket-store-j09/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::bucket-store-j09"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
    bucket = "bucket-store-j09"

    lambda_function {
        lambda_function_arn = aws_lambda_function.lambda.arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "uploads/"
    }
    depends_on = [aws_lambda_permission.s3_to_invoke_lambda]  
}

resource "aws_lambda_permission" "s3_to_invoke_lambda" {
    statement_id  = "AllowS3Invoke"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda.function_name
    principal     = "s3.amazonaws.com"
    # Replace with your S3 bucket ARN
    source_arn    = "arn:aws:s3:::bucket-store-j09"
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = "bucket-store-j09"

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "s3:GetObject",
                "Resource": "arn:aws:s3:::bucket-store-j09/*"
            }
        ]
    })

}
