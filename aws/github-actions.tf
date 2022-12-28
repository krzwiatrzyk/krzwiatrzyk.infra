resource "aws_iam_role" "github_actions" {
  name               = "github_actions"

  inline_policy {
    name   = "ecr-write-access"
    policy = data.aws_iam_policy_document.ecr_write_access.json
  }
}

data "aws_iam_policy_document" "ecr_write_access" {
  statement {
    actions   = ["ecr:*"]
    resources = ["arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/goke"]
  }
}