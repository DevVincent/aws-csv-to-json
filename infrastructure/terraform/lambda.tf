resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.snoop_raw_data

  depends_on = [
    module.lambda_function.lambda_function_arn
  ]
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.SERVICE}-csv-to-json"
  description   = "csv to json file reformater"
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_path = "../../src/server/handlers/csv-to-json"

  tags = local.common_tags
}

resource "aws_s3_bucket" "snoop_raw_data" {
  bucket_prefix = "${var.SERVICE}-raw-${var.REGION}-snoop-app"

  tags          = local.common_tags

}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.snoop_raw_data.id
  lambda_function {
    lambda_function_arn = module.lambda_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [
    module.lambda_function.lambda_function_arn,
    aws_lambda_permission.allow_bucket
  ]
    filter_prefix       = "csv-data/"
    filter_suffix       = ".csv"
}