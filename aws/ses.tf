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