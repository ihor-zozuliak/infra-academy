provider "aws" {
  region = "us-east-1"
}
resource "aws_s3_bucket" "remote-backend" {
  bucket = "remote-backend-s3-85687546754612322"
  tags = {
    Name = "remote-state"
  }
}
resource "aws_s3_bucket_acl" "remote-backend" {
  bucket = aws_s3_bucket.remote-backend.id
  acl    = "private"
}
resource "aws_dynamodb_table" "remote-backend" {
  name           = "remote-backend"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
