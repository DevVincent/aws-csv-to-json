resource "aws_s3_bucket" "snoop_json_data" {
  bucket_prefix = "${var.SERVICE}-json-${var.REGION}-snoop-app"

  tags          = local.common_tags
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