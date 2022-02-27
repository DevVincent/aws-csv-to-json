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

data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "../../src/server/handlers/csv-to-json"
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

#module "lambda_function" {
#  source = "terraform-aws-modules/lambda/aws"
#
#  function_name = "${var.SERVICE}-csv-to-json"
#  description   = "csv to json file reformater"
#  handler       = "index.handler"
#  runtime       = "nodejs14.x"
#
#  source_path = "../../src/server/handlers/csv-to-json"
#
#  tags = local.common_tags
#}

resource "aws_lambda_function" "lambda_csv_to_json" {
  filename      = "lambda.zip"
  function_name = "${var.SERVICE}-csv-to-json"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"
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
    filter_suffix       = [".csv",".pdf"]
  }

  depends_on = [
    aws_lambda_function.lambda_csv_to_json,
    aws_lambda_permission.allow_bucket
  ] 
}