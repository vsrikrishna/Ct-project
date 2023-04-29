variable "account_number" {
  type = string
  description = "AWS account number"
  default = "666796907240"
}
variable "s3_bucket_prefix" {
  type = string
  description = "AWS S3 bucket name"
  default = "ct-sri-bucket"
}
variable "r53_zone_id" {
  type = string
  description = "Route53 zone ID"
  default = "Z05997563LAADVK5W7CCX"
} 
variable "r53_domain_name" {
  type = string
  description = "Route53 Domain Name"
  default = "cointracker.srivijayapuri.cloud"
} 
