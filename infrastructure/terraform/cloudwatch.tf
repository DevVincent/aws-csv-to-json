resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter" {
  name           = "Lambda metric filter"
  log_group_name = "/aws/lambda/${aws_lambda_function.lambda_csv_to_json.function_name}"
  pattern        = "[ERROR]"
  metric_transformation {
    name      = "LambdaErrorMetric"
    namespace = "LambdaMetrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  alarm_name          = "${aws_lambda_function.lambda_csv_to_json.function_name}-alarm"
  metric_name         = aws_cloudwatch_log_metric_filter.lambda_metric_filter.name
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "ImportantMetrics"
}