resource "aws_s3_bucket" "snoop-raw-data" {
  bucket_prefix = "${var.SERVICE}-raw-${var.REGION}-snoop-app"

  tags          = local.common_tags

}

resource "aws_s3_bucket" "snoop-json-data" {
  bucket_prefix = "${var.SERVICE}-json-${var.REGION}-snoop-app"

  tags          = local.common_tags

}