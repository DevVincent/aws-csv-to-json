resource "aws_s3_bucket" "snoop-raw" {
  bucket_prefix = "${var.SERVICE}-raw-${var.REGION}-snoop-app"

  tags          = local.common_tags

}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = aws_s3_bucket.snoop-raw.id
  lambda_function {
    lambda_function_arn = module.lambda_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket" "snoop-json" {
  bucket_prefix = "${var.SERVICE}-json-${var.REGION}-snoop-app"

  tags          = local.common_tags

}