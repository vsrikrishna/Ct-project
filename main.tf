#####################
##### S3 Bucket #####
#####################
# Create s3 bucket
resource "aws_s3_bucket" "ct_sri_bucket" {
  bucket = var.s3_bucket_prefix
  tags = {
    Name        = "ct-sri-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "ct_sri_bucket_policy" {
  bucket = aws_s3_bucket.ct_sri_bucket.id
  policy = data.aws_iam_policy_document.cfn_access_policy.json
}

# bucket access policy to allow cloudfront distribution access
data "aws_iam_policy_document" "cfn_access_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.s3_bucket_prefix}/*",
    ]
    condition {
      test = "StringLike"
      variable = "AWS:SourceArn"
      values = [
        "arn:aws:cloudfront::${var.account_number}:distribution/*"
      ]
    }
  }
}


# Block public access to bucket
resource "aws_s3_bucket_public_access_block" "ct_sri_bucket_access" {
  bucket = aws_s3_bucket.ct_sri_bucket.id

  block_public_acls       = true  
  block_public_policy     = true 
  ignore_public_acls      = true 
  restrict_public_buckets = true 
}

# Default server side encryption "AES256" key is  applied
resource "aws_s3_bucket_server_side_encryption_configuration" "ct_sri_bucket_encryption" {
  bucket = aws_s3_bucket.ct_sri_bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Static website hosting configuration and serving index.html
resource "aws_s3_bucket_website_configuration" "ct_sri_bucket_static_website" {
  bucket = aws_s3_bucket.ct_sri_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# uploading index.html object
resource "aws_s3_object" "index_object" {
  bucket = aws_s3_bucket.ct_sri_bucket.id
  key    = "index.html"
  source = "./index.html"
  server_side_encryption = "AES256"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("./index.html")
}

# uploading error.html object
resource "aws_s3_object" "error_object" {
  bucket = aws_s3_bucket.ct_sri_bucket.id
  key    = "error.html"
  source = "./error.html"
  server_side_encryption = "AES256"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("./error.html")
}



### SSL Certificate #######
resource "aws_acm_certificate" "ssl_certificate" {
  provider                  = aws
  domain_name               = var.r53_domain_name
  subject_alternative_names = ["*.${var.r53_domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}


###################
#### CLOUDFRONT #####
###################

# Origin Access ID for s3
resource "aws_cloudfront_origin_access_control" "ct_sri_oai" {
  name                              = "ct_sri_oai"
  description                       = "Access Policy for s3 access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

locals {
  s3_origin_id = aws_s3_bucket.ct_sri_bucket.bucket_regional_domain_name
}

# main cloudfront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.ct_sri_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.ct_sri_oai.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "Cointracker Sri Project distribution"
  default_root_object = "index.html"


  aliases = ["cointracker.srivijayapuri.cloud"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/test"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      headers      = ["Origin"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100" #Supporting only requests from USA, Mexico and Canada

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  tags = {
    Environment = "development"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.ssl_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

}

#### Route53 #######
# updating route53 record to point at cloudfront created above
resource "aws_route53_record" "r53_cloudfront" {
  zone_id = var.r53_zone_id
  name    = var.r53_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

