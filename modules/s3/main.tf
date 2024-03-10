resource "aws_s3_bucket" "S3Bucket" {
   bucket = "codepipeline-files-${formatdate("YYYY-MM-DD-HH-mm-ss", timestamp())}"
   force_destroy  = true
}