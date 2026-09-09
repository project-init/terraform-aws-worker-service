########################################################################################################################
### Common
########################################################################################################################

variable "environment" {
  type        = string
  nullable    = false
  description = "The environment to deploy the worker service to."
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ecs cluster to deploy the service on."
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ecs cluster to deploy the service on."
}

variable "worker_name" {
  type        = string
  nullable    = false
  description = "The name of the worker."
}

variable "service_name" {
  type        = string
  nullable    = false
  description = "The name of the service."
}

########################################################################################################################
### ECS Cluster/Service
########################################################################################################################

variable "subnets" {
  type        = set(string)
  description = "The subnets to deploy the service in to."
}

variable "security_groups" {
  type        = list(string)
  description = "IDs of the extra security groups you want the task to have access to."
}

variable "use_ec2" {
  type        = bool
  default     = false
  description = "Whether to deploy the service on an ec2 backed service or fargate."
}

variable "capacity_providers" {
  default = []
  type = set(object({
    capacity_provider = string
    base              = number
    weight            = number
  }))
  description = "List of capacity providers to use for distributing tasks. Should primarily be used when utilizing ec2 backed ecs."
}

variable "ordered_placement_strategies" {
  default = []
  type = set(object({
    type  = string
    field = string
  }))
  description = "List of ordered placement strategies to use for distributing tasks. Should primarily be used when utilizing ec2 backed ecs."
}

variable "force_new_deployment" {
  type        = bool
  default     = false
  description = "Whether to force a new deployment when updating the ecs service."
}

########################################################################################################################
### ECS Task
########################################################################################################################

variable "iam_policies" {
  type        = map(string)
  default     = {}
  nullable    = false
  description = "Map of inline policy names to IAM policy JSON documents to attach to the worker task role."
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "The environment variables to use for the service."
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default     = []
  description = "The secrets to use for the service."
}

variable "image" {
  type        = string
  nullable    = false
  description = "The docker image to use for the container."
}

variable "desired_count" {
  type        = number
  default     = 0
  description = "Desired count of tasks to run. This is ignored after the first apply."
}

variable "max_capacity" {
  type        = number
  default     = 0
  description = "The maximum amount of the tasks to run."
}

variable "min_capacity" {
  type        = number
  default     = 0
  description = "The minimum amount of the tasks to run."
}

variable "cpu" {
  type        = number
  default     = 256
  description = "The cpu value to give to the ecs task."
}

variable "memory" {
  type        = number
  default     = 512
  description = "The memory value to give to the ecs task."
}

########################################################################################################################
### Security/Networking
########################################################################################################################

variable "vpc_id" {
  type        = string
  nullable    = false
  description = "The VPC ID being deployed to."
}
