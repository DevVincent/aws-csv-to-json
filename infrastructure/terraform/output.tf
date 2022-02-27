output "raw_bucket" {
    value = aws_s3_bucket.snoop_raw_data.id
}

output "json_bucket" {
    value = aws_s3_bucket.snoop_json_data.id
}

output "lambda_function" {
    value = aws_lambda_function.lambda_csv_to_json.function_name
}

output "kms_key_arn" {
    value = aws_kms_key.kms_s3_key.arn
}

output "kms_key_id" {
    value = aws_kms_key.kms_s3_key.key_id
}

output "kms_key_alais_arn" {
    value = aws_kms_alias.kms_key_alias.arn
}

output "kms_key_alias_name" {
    value = aws_kms_alias.kms_key_alias.name
}