resource "aws_s3_bucket" "site" {
  bucket = var.site_name
  acl    = "private"
  policy = data.aws_iam_policy_document.bucket_policy.json

  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    "Name" = var.site_name
  }
  
}

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.site_name}"
  acl    = "private"
  policy = ""

  force_destroy = true

  website {
    redirect_all_requests_to = "https://${var.site_name}"
  }

  tags = {
    "Name" = "www.${var.site_name}"
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid = "AllowReadFromAll"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.site_name}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

