resource "aws_api_gateway_rest_api" "private_api" {
  name        = var.api_name
  description = "Private REST API for Lambda trigger"
  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = [var.vpce_id]
  }
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "execute-api:Invoke",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id
  parent_id   = aws_api_gateway_rest_api.private_api.root_resource_id
  path_part   = var.pod_path
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.private_api.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-northeast-2:lambda:path/2015-03-31/functions/${var.lambda_invoke_arn}/invocations"
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.private_api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "rds_resource" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id
  parent_id   = aws_api_gateway_rest_api.private_api.root_resource_id
  path_part   = var.rds_path
}

resource "aws_api_gateway_method" "rds_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  resource_id   = aws_api_gateway_resource.rds_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rds_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.private_api.id
  resource_id             = aws_api_gateway_resource.rds_resource.id
  http_method             = aws_api_gateway_method.rds_get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:ap-northeast-2:lambda:path/2015-03-31/functions/${var.rds_lambda_invoke_arn}/invocations"
}

resource "aws_lambda_permission" "rds_apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvokeRDS"
  action        = "lambda:InvokeFunction"
  function_name = var.rds_lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.private_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.lambda_resource.id,
      aws_api_gateway_method.get_method.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_resource.rds_resource.id,
      aws_api_gateway_method.rds_get_method.id,
      aws_api_gateway_integration.rds_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  stage_name    = "prod"
}