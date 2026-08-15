variable "project_name" {
  type = string
}

variable "launch_template_id" {
  type = string
}

variable "launch_template_version" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "public_subnet_1_id" {
  type = string
}

variable "public_subnet_2_id" {
  type = string
}

variable "min_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}

variable "max_size" {
  type = number
}

variable "scale_out_cpu" {
  type = number
}

variable "scale_in_cpu" {
  type = number
}