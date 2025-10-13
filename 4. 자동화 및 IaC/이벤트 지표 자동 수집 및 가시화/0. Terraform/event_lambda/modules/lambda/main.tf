data "archive_file" "create_event_json" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/code/function.zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.function_name
  role          = var.role_arn
  handler       = var.handler
  runtime       = var.runtime
  vpc_config {
    subnet_ids         = var.vpc_config.subnet_ids
    security_group_ids = var.vpc_config.security_group_ids
  }
  source_code_hash = data.archive_file.create_event_json.output_base64sha256
  filename         = data.archive_file.create_event_json.output_path
  environment {
    variables = var.environment
  }
  timeout = var.timeout
}
