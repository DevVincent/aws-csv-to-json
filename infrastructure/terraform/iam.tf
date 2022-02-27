data aws_iam_policy_document lambda_role_csv_policy {

  statement {
    sid = "CloudWatch"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    sid = "KMSOperations"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }

  statement {
    sid = "S3PutToExternalBucket"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [aws_s3_bucket.snoop_json_data, aws_s3_bucket.snoop_raw_data]
  }
}

data aws_iam_policy_document lambda_trust_relationship_policy {
  statement {
    sid = "AllowLambda"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource aws_iam_role lambda_role {
  name                = "${var.SERVICE}-${var.STAGE}-lambda"
  assume_role_policy  = data.aws_iam_policy_document.lambda_trust_relationship_policy.json
}

resource aws_iam_policy lambda_policy {
  name        = "${var.SERVICE}-${var.STAGE}-lambda"
  description = "${var.SERVICE}-${var.STAGE}-lambda"
  policy      = data.aws_iam_policy_document.lambda_role_csv_policy.json
}

resource aws_iam_role_policy_attachment lambda_role_permission {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
