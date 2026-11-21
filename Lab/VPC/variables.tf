variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = list(string)
  default     = ["172.20.0.0/16", "172.20.10.0/24"]
}