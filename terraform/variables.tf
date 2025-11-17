variable "vpc_cidr" {
  description = "CIDR untuk vpc"
  type = string
}

variable "subnet_cidr" {
  description = "CIDR untuk subnet"
  type = string
}

variable "availibility_zone" {
  description = "Lokasi instance"
  type = string
}

variable "environment_prefix" {
  description = "Prefix resource"
  type = string
}

variable "my_ip" {
  description = "IP Publik saya"
  type = string
}

variable "my_public_key" {
  description = "Public Key saya"
  type = string
}

variable "access_key" {
  description = "access key akun aws"
  type = string
}

variable "secret_access_key" {
  description = "secret access key akun aws"
  type = string
}

variable "instance_type" {
  description = "Tipe instance"
  type = string
  default = "t3.small"
}