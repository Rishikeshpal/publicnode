variable "project_name" {
  description = "Prefix used for naming AWS resources."
  type        = string
  default     = "score"
}

variable "region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "allowed_ip_cidr" {
  description = "Single IPv4 CIDR (e.g. 203.0.113.10/32) allowed to reach the public instance."
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access."
  type        = string
}

variable "public_instance_type" {
  description = "EC2 instance type for the public (bastion) host."
  type        = string
  default     = "t3.micro"
}

variable "private_instance_type" {
  description = "EC2 instance type for the private host."
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Additional tags to attach to created resources."
  type        = map(string)
  default     = {}
}


