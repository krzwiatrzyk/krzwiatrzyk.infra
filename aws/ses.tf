resource "aws_ses_domain_identity" "windkube" {
  domain = "windkube.com"
}

resource "aws_route53_record" "windkube_ses" {
  zone_id = var.windkube_zone_id
  name    = "_amazonses.${aws_ses_domain_identity.windkube.id}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.windkube.verification_token]
}

resource "aws_ses_domain_identity_verification" "windkube" {
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
}