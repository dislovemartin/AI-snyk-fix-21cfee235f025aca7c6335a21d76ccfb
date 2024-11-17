variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "ai-platform-vpc"
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
  default     = 3
} 