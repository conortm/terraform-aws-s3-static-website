variable "domain_name" {
  description = "Domain name for the website (i.e. www.example.com)"
  type        = "string"
}

variable "redirects" {
  description = "A list of domain names which redirect to domain_name"
  default     = []
}

variable "public_dir" {
  description = "Directory from which to serve public files (default: /public)"
  default     = "/public"
}

variable "secret" {
  description = "A secret string between CloudFront and S3 to control access"
  type        = "string"
}

variable "cert_arn" {
  description = "ARN of the SSL Certificate to use for the Cloudfront Distribution"
  type        = "string"
}

variable "zone_id" {
  description = "ID of the Route 53 Hosted Zone in which to create an alias record"
  type        = "string"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
