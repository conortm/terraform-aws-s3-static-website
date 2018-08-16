# AWS S3 Static Website

Terraform Module for an Amazon S3 Static Website.

## Features

TK

## Usage

```HCL
module "static_website" {
  source = "git@github.com:conortm/terraform-aws-s3-static-website.git"

  domain_name = "www.my-aws-s3-static-website.com"
  redirects   = ["my-aws-s3-static-website.com"]
  secret      = "SOME_SECRET_MANAGED_OUTSIDE_OF_VERSION_CONTROL"
  cert_arn    = "ARN_OF_SSL_CERTIFICATE"
  zone_id     = "HOSTED_ZONE_ID"

  tags = {
    Foo = "Bar"
  }
}
```

## Inputs

TK

## TODO

- [ ] Expose more configuration of resources, esp. Cloudfront dist.
- [ ] Better way to pass in SSL cert, Hosted Zone ID, etc.
- [ ] Better way to implement Cloudfront-to-S3 access than secret?
