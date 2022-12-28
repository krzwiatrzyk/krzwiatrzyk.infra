data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

data "aws_region" "ses" {
  provider = aws.ses
}

data "aws_region" "current" {}