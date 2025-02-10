resource "aws_ecr_repository" "divya-reg" {
  name                 = "node"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "scalable-frontend-example"
    labels = {
      App = "ScalableFrontendExample"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "ScalableFrontend"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableFrontend"
        }
      }
      spec {
        container {
          image = "490004643334.dkr.ecr.us-west-1.amazonaws.com/node:latest"
          name  = "ScalableFrontend"

          port {
            container_port = 3000
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend-svc"
  }
  spec {
    selector = {
      App = kubernetes_deployment.frontend.spec.0.template.0.metadata[0].labels.App
    }
    port {
      node_port   = 30201
      port        = 3000
      target_port = 3000
    }

    type = "NodePort"
  }
}

resource "aws_dynamodb_table" "state__lock_table" {
  name         = "state-lock-bcvket"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}
resource "aws_s3_bucket" "state_bucket" {
  bucket = "divya-tf-state-bucket"
  force_destroy = true

}
resource "aws_s3_bucket_versioning" "s3-version" {
    bucket =aws_s3_bucket.state_bucket.id
    versioning_configuration {
      status =  "Enabled"
    }
  
}
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}