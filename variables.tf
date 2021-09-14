variable "cert_arn" {
  description = "ARN of the SSL Certificate to use for the Cloudfront Distribution"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the website (i.e. www.example.com)"
  type        = string
}

variable "public_dir" {
  description = "Directory in S3 Bucket from which to serve public files (no leading or trailing slashes)"
  default     = public
}

variable "redirects" {
  description = "A list of domains that should redirect to domain_name (i.e. for redirecting naked domain to www-version)"
  default     = []
}

variable "secret" {
  description = "A secret string between CloudFront and S3 to control access"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to each resource"
  default     = {}
}

variable "zone_id" {
  description = "ID of the Route 53 Hosted Zone in which to create an alias record"
  type        = string
}
