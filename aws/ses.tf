resource "aws_ses_domain_identity" "windkube" {
  domain = "windkube.com"
  provider = aws.ses
}

resource "aws_route53_record" "windkube_ses" {
  provider = aws.ses
  zone_id = var.windkube_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.windkube.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.windkube.verification_token]
}

resource "aws_ses_domain_identity_verification" "windkube" {
  provider = aws.ses
  domain = aws_ses_domain_identity.windkube.id

  depends_on = [aws_route53_record.windkube_ses]
}

resource "aws_iam_user" "ghost_blog" {
  name = "ghost_blog"
}

resource "aws_iam_access_key" "ghost_blog" {
  user = aws_iam_user.ghost_blog.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses_sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "ghost_blog_ses_sender" {
  user       = aws_iam_user.ghost_blog.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

output "ghost_blog_username" {
  value = aws_iam_access_key.ghost_blog.id
}

output "ghost_blog_password" {
  value = aws_iam_access_key.ghost_blog.ses_smtp_password_v4
  sensitive = true
}

resource "aws_route53_record" "mail" {
  zone_id = var.windkube_zone_id
  name    = "windkube.com"
  type    = "MX"
  ttl     = 60
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "aws_s3_bucket" "mail" {
  bucket = "windkube-mails"

  tags = {
    ManagedBy        = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "mail" {
  bucket = aws_s3_bucket.mail.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "mail" {
  bucket = aws_s3_bucket.mail.id
  policy = data.aws_iam_policy_document.mail.json
}

data "aws_iam_policy_document" "mail" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.mail.arn}/*",
    ]

    condition {
      test = "StringEquals"
      variable = "AWS:SourceAccount"
      values = [local.account_id]
    }

    # condition {
    #   test = "StringEquals"
    #   variable = "AWS:SourceArn"
    #   values = ["arn:aws:ses:${aws.ses.region}:${local.account_id}:receipt-rule-set/rule_set_name:receipt-rule/receipt_rule_name"]
    # }

  }
}
