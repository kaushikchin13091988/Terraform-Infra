variable "vpc_id" {
  type = string
}

variable "public_subnet_1_id" {
  type = string
}

variable "public_subnet_2_id" {
  type = string
}

variable "security_group_allow_http_traffic_id" {
  type = string
}

variable "alb_id" {
  type = string
}

variable "target_group_id" {
  type = string
}

# variable "EcsServiceExecutionRole" {
#   type = string
# }