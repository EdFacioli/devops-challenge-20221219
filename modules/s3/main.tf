locals {
  bucketName = "${var.environment_id}-${var.appName}-benice"
}

resource "aws_s3_bucket" "main" {
  bucket = local.bucketName

  tags = {
    Name        = local.bucketName
    Environment = var.environment_id
  }
}

resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "main" {
  bucket = aws_s3_bucket.main.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

}

resource "aws_s3_bucket_policy" "PolicyForCloudFrontPrivateContent" {
  bucket = aws_s3_bucket.main.id
  policy = <<POLICY
  {    
    "Version": "2008-10-17",    
    "Statement": [        
      {            
          "Sid": "PublicReadGetObject",            
          "Effect": "Allow",            
          "Principal": "*",            
          "Action": [                
             "s3:GetObject"            
          ],            
          "Resource": [
             "arn:aws:s3:::${aws_s3_bucket.main.id}/*"            
          ]        
      }    
    ]
  }
  POLICY
}
