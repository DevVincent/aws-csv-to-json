resource "aws_s3_bucket" "snoop_json_data" {
  bucket_prefix = "${var.SERVICE}-json-${var.REGION}-snoop-app"

  tags          = local.common_tags

}