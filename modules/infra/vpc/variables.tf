variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
}
variable "dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC"
  type        = bool
  default     = true
}
variable "dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = true
}
variable "tenancy" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = string
  default     = "default" # "default" or "dedicated"
}
variable "network_metrics" {
  description = "Indicates whether Network Address Usage metrics are enabled for your VPC"
  type        = bool
  default     = false
}
variable "az" {}
variable "subnet_cidr" {}
variable "environment" {}
variable "owner" {}
