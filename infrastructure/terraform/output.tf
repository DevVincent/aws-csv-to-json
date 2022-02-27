output raw_bucket {
    value = aws_s3_bucket.snoop_raw_data.id
}

output json_bucket {
    value = aws_s3_bucket.snoop_json_data.id
}

output lambda {
    value = aws_lambda_function.lambda_csv_to_json.function_name
}