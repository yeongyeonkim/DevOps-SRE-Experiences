module "lambda" {
  source        = "./modules/lambda"
  function_name = var.lambda_name
  role_arn      = var.lambda_role_arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  vpc_config    = var.vpc_config
  environment   = var.lambda_environment
  timeout       = var.lambda_timeout
}

# trigger 1 
module "eventbridge" {
  source        = "./modules/eventbridge"
  rule_name     = var.eventbridge_rule_name
  schedule_expr = var.eventbridge_schedule_expr
  lambda_arn    = module.lambda.lambda_arn
  lambda_name   = var.lambda_name
}

# trigger 2
module "apigw" {
  source                = "./modules/apigw"
  api_name              = var.apigw_name
  vpce_id               = var.apigw_vpce_id
  pod_path              = var.apigw_pod_path
  rds_path              = var.apigw_rds_path
  lambda_invoke_arn     = module.lambda.lambda_arn
  lambda_name           = var.lambda_name
  rds_lambda_invoke_arn = var.rds_lambda_invoke_arn
  rds_lambda_name       = var.rds_lambda_name
}
