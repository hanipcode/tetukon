variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "service_names" {
  description = "List of service names"
  type        = list(string)
}

variable "service_ports" {
  description = "Map of service names to their ports"
  type        = map(number)
} 