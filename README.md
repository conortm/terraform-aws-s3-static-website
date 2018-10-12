# AWS S3 Static Website Terraform Module

[Terraform Module](https://registry.terraform.io/modules/conortm/s3-static-website) for an Amazon S3 Static Website, fronted by a CloundFront Distribution.

**Note:** This module "works" but is still in development. See [TODO section](#todo). Also, suggestions welcome!

## Features

This module allows for [Hosting a Static Website on Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/WebsiteHosting.html), provisioning the following:

- S3 Bucket for static public files
- CloudFront Distribution fronting the S3 Bucket
- Route 53 Record Set aliased to the CloudFront Distribution

It requires (for now?) that the following have been setup outside this module:

- SSL Certificate
- Route 53 Hosted Zone

## Usage

```HCL
module "s3-static-website" {
  source  = "conortm/s3-static-website/aws"

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

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-------:|:--------:|
| cert_arn | ARN of the SSL Certificate to use for the Cloudfront Distribution | string | - | yes |
| domain_name | Domain name for the website (i.e. `www.example.com`) | string | - | yes |
| public_dir | Directory in S3 Bucket from which to serve public files (no leading or trailing slashes) | string | `public` | no |
| redirects | A list of domains that should redirect to domain_name (i.e. for redirecting naked domain to www-version) | list | `<list>` | no |
| secret | A secret string between CloudFront and S3 to control access | string | - | yes |
| tags | A mapping of tags to assign to each resource | map | `<map>` | no |
| zone_id | ID of the Route 53 Hosted Zone in which to create an alias record set | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| cdn_domain_name | Domain name of the Cloudfront Distribution |

## TODO

- [ ] Expose more configuration of resources, esp. Cloudfront dist.
- [ ] Better way to pass in SSL cert, Hosted Zone ID, etc.
- [ ] Add more outputs.
