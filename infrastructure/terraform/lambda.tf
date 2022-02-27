module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.SERVICE}-csv-to-json"
  description   = "csv to json file reformater"
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_path = "../../src/server/handlers/csv-to-json"

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.snoop_raw_data

  depends_on = [
    module.lambda_function
  ]
}