resource "aws_ecr_repository" "goke" {
  name                 = "goke"
}

resource "aws_ecr_registry_scanning_configuration" "configuration" {
  scan_type = "BASIC"
}