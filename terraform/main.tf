# resource "aws_ecr_repository" "divya-reg" {
#   name                 = "node"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# resource "aws_ecr_repository" "divya-reg2" {
#   name                 = "api"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }
# resource "aws_dynamodb_table" "state__lock_table" {
#   name         = "state-lock-bcvket"
#   hash_key     = "LockID"
#   billing_mode = "PAY_PER_REQUEST"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
# resource "aws_s3_bucket" "state_bucket" {
#   bucket = "divya-tf-state-bucket"
#   force_destroy = true

# }
# resource "aws_s3_bucket_versioning" "s3-version" {
#     bucket =aws_s3_bucket.state_bucket.id
#     versioning_configuration {
#       status =  "Enabled"
#     }
  
# }
# resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
#   bucket = aws_s3_bucket.state_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm     = "AES256"
#     }
#   }
# }