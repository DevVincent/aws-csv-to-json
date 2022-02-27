#resource "aws_iam_role" "iam_for_lambda" {
#  name = "iam_for_lambda"
#
#  assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "lambda.amazonaws.com"
#      },
#      "Effect": "Allow"
#    }
#  ]
#}
#EOF
#}

data "aws_iam_policy_document" "lambda_role_policy" {
  
  statement {
    sid = "AllowLambda"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }

  statement {
    sid = "CloudWatch"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid = "KMSOperations"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }

  statement {
    sid = "S3Get"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]

    resources = ["*"]
  }

  statement {
    sid = "S3PutToExternalBucket"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]

    resources = ["*"]
  }
}

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "../../src/server/handlers/lambda"
    output_path = "lambda.zip"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_csv_to_json.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.snoop_raw_data.arn

  depends_on = [
    aws_lambda_function.lambda_csv_to_json
  ]
}

resource "aws_lambda_function" "lambda_csv_to_json" {
  filename      = "lambda.zip"
  function_name = "${var.SERVICE}-csv-to-json"
  role          = data.aws_iam_policy_document.lambda_role_policy
  handler       = "index.lambda-handler"
  runtime       = "python3.9"
}

resource "aws_s3_bucket" "snoop_raw_data" {
  bucket_prefix = "${var.SERVICE}-raw-${var.REGION}-snoop-app"

  tags          = local.common_tags

}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.snoop_raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_csv_to_json.arn
    events              = ["s3:ObjectCreated:*"]

    filter_prefix       = "csv-data/"
    filter_suffix       = ".csv"
  }

  depends_on = [
    aws_lambda_function.lambda_csv_to_json,
    aws_lambda_permission.allow_bucket
  ] 
}