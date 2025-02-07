resource "aws_ecr_repository" "divya-reg" {
  name                 = "node"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_image" "service_image" {
  repository_name = "my/service"
  image_tag       = "latest"
}