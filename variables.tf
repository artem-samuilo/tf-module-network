variable "env"{
  type        = string
}
variable "vpc_cidr" {
  type        = string
}

variable availability_zones {
  type        = list(string)
}

variable public_subnets_count {
  type        = number
}

variable private_subnets_count {
  type        = number
}

variable newbits {
  type        = number
}