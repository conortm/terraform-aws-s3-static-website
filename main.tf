locals {
  public_dir_with_leading_slash = "${length(var.public_dir) > 0 ? "/${var.public_dir}" : ""}"
  static_website_routing_rules  = <<EOF
[{
    "Condition": {
        "KeyPrefixEquals": "${var.public_dir}/${var.public_dir}/"
    },
    "Redirect": {
        "Protocol": "https",
        "HostName": "${var.domain_name}",
        "ReplaceKeyPrefixWith": "",
        "HttpRedirectCode": "301"
    }
}]
EOF
}

resource "aws_s3_bucket" "static_website" {
  bucket = "${var.domain_name}"

  website {
    index_document = "index.html"
    error_document = "error.html"

    routing_rules = "${length(var.public_dir) > 0 ? local.static_website_routing_rules : ""}"
  }

  tags = "${merge(map("Name", "${var.domain_name}-static_website"), var.tags)}"
}

data "aws_iam_policy_document" "static_website_read_with_secret" {
  statement {
    sid       = "1"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_website.arn}${local.public_dir_with_leading_slash}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:UserAgent"
      values   = [var.secret]
    }
  }
}

resource "aws_s3_bucket_policy" "static_website_read_with_secret" {
  bucket = "${aws_s3_bucket.static_website.id}"
  policy = "${data.aws_iam_policy_document.static_website_read_with_secret.json}"
}

locals {
  s3_origin_id = "cloudfront-distribution-origin-${var.domain_name}.s3.amazonaws.com${local.public_dir_with_leading_slash}"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = "${aws_s3_bucket.static_website.website_endpoint}"
    origin_path = "${local.public_dir_with_leading_slash}"
    origin_id   = "${local.s3_origin_id}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }

    custom_header {
      name  = "User-Agent"
      value = var.secret
    }
  }

  comment             = "CDN for ${var.domain_name} S3 Bucket"
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases             = ["${var.domain_name}"]

  custom_error_response {
    error_code         = 403
    response_page_path = "/error.html"
    response_code      = 404
  }

  custom_error_response {
    error_code         = 404
    response_page_path = "/error.html"
    response_code      = 404
  }

  default_cache_behavior {
    target_origin_id = "${local.s3_origin_id}"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.cert_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = "${merge(map("Name", "${var.domain_name}-cdn"), var.tags)}"
}


resource "aws_s3_bucket" "redirect" {
  for_each = var.redirects
  bucket   = each.value
  website {
    redirect_all_requests_to = "https://${var.domain_name}"
  }
  tags = "${merge(map("Name", each.key), var.tags)}"
}

resource "aws_cloudfront_distribution" "redirect" {
  for_each = var.redirects
  origin {
    domain_name = each.value
    origin_id   = "cloudfront-distribution-origin-${each.key}.s3.amazonaws.com"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
  }

  comment         = "CDN for ${each.value} S3 Bucket (redirect)"
  enabled         = true
  is_ipv6_enabled = true
  aliases         = ["${each.value}"]

  default_cache_behavior {
    target_origin_id = "cloudfront-distribution-origin-${each.key}.s3.amazonaws.com"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${var.cert_arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  tags = "${merge(map("Name", "${each.key}-cdn_redirect"), var.tags)}"
}

resource "aws_route53_record" "alias" {
  #count = "${length(var.zone_id) > 0 ? 1 : 0}"

  zone_id = "${var.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.cdn.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.cdn.hosted_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect" {
  #count = "${length(var.zone_id) > 0 ? length(var.redirects) : 0}"

  for_each = var.redirects
  zone_id  = "${var.zone_id}"
  # Work-around (see: https://github.com/hashicorp/terraform/issues/11210)
  name = each.key
  type = "A"

  alias {
    name                   = each.value
    zone_id                = each.value
    evaluate_target_health = false
  }
}
