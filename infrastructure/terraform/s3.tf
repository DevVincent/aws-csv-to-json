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
    module.lambda_function.lambda_function_arn
  ]
}

resource "aws_s3_bucket" "snoop_json_data" {
  bucket_prefix = "${var.SERVICE}-json-${var.REGION}-snoop-app"

  tags          = local.common_tags

}