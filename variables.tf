variable "account_number" {
  type = string
  description = "AWS account where all the infrastructure will be setup"
  default = "666796907240"
}
variable "s3_bucket_prefix" {
  type = string
  description = "AWS S3 bucket name which will host the static website serving the page"
  default = "ct-sri-bucket"
}
variable "r53_zone_id" {
  type = string
  description = "Route53 zone ID for private domain srvijayapuri.cloud"
  default = "Z05997563LAADVK5W7CCX"
} 
variable "r53_domain_name" {
  type = string
  description = "Route53 Domain Name for the test cointracker project page"
  default = "cointracker.srivijayapuri.cloud"
} 
