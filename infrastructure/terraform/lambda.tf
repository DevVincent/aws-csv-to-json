module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "${var.SERVICE}-csv-to-json"
  description   = "csv to json file reformater"
  handler       = "index.handler"
  runtime       = "node14"

  source_path = "../../src/server/handlers/csv-to-json"

  tags = local.common_tags
}