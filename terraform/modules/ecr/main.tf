# ECRリポジトリの作成
resource "aws_ecr_repository" "knowledgebase_ecr_repo" {
  name                 = "knowledgebase-ecr-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

# --- イメージのビルドとプッシュ ---

locals {
  repo_url = aws_ecr_repository.knowledgebase_ecr_repo.repository_url
}
resource "null_resource" "knowledgebase_image" {
  triggers = {
    hash = md5(join("-", [for x in fileset("", "./{*.py,*.tsx,Dockerfile}") : filemd5(x)]))
  }

  provisioner "local-exec" {
    command = <<EOF
      aws ecr get-login-password | docker login --username AWS --password-stdin ${local.repo_url}
      docker build --platform linux/amd64 -t ${local.repo_url}:latest ../../../
      docker push ${local.repo_url}:latest
    EOF
  }
}


data "aws_ecr_image" "knowledgebase_latest_image" {
  repository_name = aws_ecr_repository.knowledgebase_ecr_repo.name
  image_tag       = "latest"
  depends_on      = [null_resource.knowledgebase_image]
}
