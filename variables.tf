variable "zone_name" {}
variable "shared_credentials_file" {}
variable "profile" {}
variable "region" {}
variable "elb_us_zone_id" {}
variable "elb_eu_zone_id" {}
variable "elb_ap_zone_id" {}
variable "ttl" {
  default = "300"
}
variable "is_mx" {
  type    = bool
  default = false
}
variable "is_cname" {
  type    = bool
  default = false
}
variable "is_alb" {
  type    = bool
  default = false
}
