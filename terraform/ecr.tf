resource "aws_ecr_repository" "tf_batch_ecr" {
  for_each             = toset(local.dockerfiles)
  name                 = each.key
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
