variable "deploy_role_arn" {
  type        = string
  description = "Provided by Jenkins CI/CD"
}

variable "project_prefix" {
  type        = string
  description = "Project Prefix"
}

variable "env" {
  type        = string
  description = "Environment"
}

variable "vpc_config" {
  type = object({
    name               = string
    cidr               = string
    network_acls_ports = map(list(string))
    subnets = map(list(object({
      az   = string
      cidr = string
    })))
  })
  description = "VPC Configuration"
}
