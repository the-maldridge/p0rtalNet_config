resource "aws_s3_bucket" "joycespiveyaldridge_com" {
  bucket = "joycespiveyaldridge.com"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}
