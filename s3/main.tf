provider "aws" {
  region = "ap-south-1"
}


resource "aws_s3_bucket" "a-s3" {
  bucket = "brijendra-2003-a2"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.a-s3.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "upload_file" {
  bucket = aws_s3_bucket.a-s3.id
  key    = "files/index.html"
  source = "./index.html"

  etag = filemd5("./index.html")
}

resource "aws_s3_bucket_lifecycle_configuration" "my-s3-lifecycle" {
  bucket = aws_s3_bucket.a-s3.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-access-role-2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access" {
  name = "ec2-s3-access-policy-2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.a-s3.arn,
          "${aws_s3_bucket.a-s3.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}


output "bucket" {
  value = aws_s3_bucket.a-s3
}

output "role_name" {
  value = aws_iam_role.ec2_role.name
}
