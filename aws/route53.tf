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