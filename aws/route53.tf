locals {
  iam_role_policy_text=file("${path.module}/iam_roles/cert-manager-route-53.json")
  iam_role_policy_json=jsonencode(file("${path.module}/iam_roles/cert-manager-route-53.json"))
}

# data "aws_iam_policy_document" "inline_policy" {
#   statement {
#     actions   = ["ec2:DescribeAccountAttributes"]
#     resources = ["*"]
#   }
# }

resource "aws_iam_user" "cert_manager" {
  name = "cert_manager"
  path = "/system/"

  tags = {
    ManagedBy = "Terraform"
  }

}

resource "aws_iam_access_key" "cert_manager" {
  user = aws_iam_user.cert_manager.name
}

resource "aws_iam_user_policy" "cert_manager" {
  name = "cert_manager"
  user = aws_iam_user.cert_manager.name

  policy = local.iam_role_policy_text
}

output "cert_manager_secret_key" {
  value = aws_iam_access_key.cert_manager.secret
  sensitive = true
}

output "cert_manager_access_key" {
  value = aws_iam_access_key.cert_manager.id
}

resource "aws_route53_record" "bayek" {
  zone_id = var.windkube_zone_id
  name    = "*.bayek.windkube.com"
  type    = "A"
  ttl     = 60
  records = [var.bayek_cluster_ip]
}

resource "aws_route53_record" "bkf" {
  zone_id = var.windkube_zone_id
  name    = "*.bkf.windkube.com"
  type    = "A"
  ttl     = 60
  records = [var.bkf_cluster_ip]
}

resource "aws_route53_record" "windkube" {
  zone_id = var.windkube_zone_id
  name    = "*.windkube.com"
  type    = "A"
  ttl     = 60
  records = [var.normandy_cluster_ip]
}

resource "aws_route53_record" "mirai" {
  zone_id = var.windkube_zone_id
  name    = "*.mirai.windkube.com"
  type    = "A"
  ttl     = 60
  records = [var.mirai_cluster_ip]
}