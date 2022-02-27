resource "aws_kms_key" "kms_s3_key" {
  description = "kms key for s3"
  deletion_window_in_days = 7

  tags = local.common_tags
}

resource "aws_kms_alias" "kms_key_alias" {
  name = "alias/${lower("${var.SERVICE}-s3-kms-key")}"
  target_key_id = aws_kms_key.kms_s3_key.key_id
}
