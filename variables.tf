variable "server_type" {
  default     = "t3.micro"
  type        = string
  description = "String"
}

variable "server_count" {
  default     = "1"
  type        = number
  description = "Number"
}

variable "termination_protection" {
  default     = false
  type        = bool
  description = "Bool"
}

variable "secondary_ips_pri" {
  type        = list(string)
  default     = ["172.16.10.200", "172.16.10.201"]
  description = "List of strings"
}

variable "server_tags" {
  type = map(string)
  default = {
    Name       = "Webserver"
    ID         = 10000987
    Terrafrorm = true
  }
  description = "Map of strings"
}

variable "waf_ips" {
  type = map(object({
    name        = string
    description = string
    addresses   = list(string)
  }))
  default = {
    "us" = {
      name        = "usa"
      description = "USA offices VPN"
      addresses   = ["10.100.23.30/32", "95.32.201.11/32"]
    }
    "eu" = {
      name        = "europe"
      description = "Europe offices VPN"
      addresses   = ["15.200.223.10/32", "17.15.21.111/32"]
    }
  }
  description = "Map object"
}
