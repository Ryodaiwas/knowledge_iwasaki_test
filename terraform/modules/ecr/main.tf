
# Creating an ECR Repository
resource "aws_ecr_repository" "knowledgebase-test-ecr-repo" {
  name                 = "knowledgebase-test-ecr-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- Build & push image ---

locals {
  repo_url = aws_ecr_repository.knowledgebase-test-ecr-repo.repository_url
}

resource "null_resource" "image" {
  triggers = {
    hash = md5(join("-", [for x in fileset("", "./{*.py,*.tsx,Dockerfile}") : filemd5(x)]))
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password | docker login --username AWS --password-stdin ${local.repo_url}
      docker build --platform linux/amd64 -t ${local.repo_url}:latest .
      docker push ${local.repo_url}:latest
    EOF
  }
}

data "aws_ecr_image" "latest" {
  repository_name = aws_ecr_repository.knowledgebase-test-ecr-repo.name
  image_tag       = "latest"
  depends_on      = [null_resource.image]
}

