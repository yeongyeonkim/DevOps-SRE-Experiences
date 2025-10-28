variable "region" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "rds_lambda_name" {
  type = string
}

variable "rds_lambda_invoke_arn" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_runtime" {
  type = string
}

variable "lambda_environment" {
  type = map(string)
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
}

variable "lambda_timeout" {
  type = number
}

variable "eventbridge_rule_name" {
  type = string
}

variable "eventbridge_schedule_expr" {
  type = string
}

variable "apigw_name" {
  type = string
}

variable "apigw_vpce_id" {
  type = string
}

variable "apigw_pod_path" {
  type = string
}

variable "apigw_rds_path" {
  type = string
}
