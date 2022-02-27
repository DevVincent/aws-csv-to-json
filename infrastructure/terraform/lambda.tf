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
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.8"
}
