resource "aws_lambda_layer_version" "generic_stuff_layer" {
  filename            = local.layer_jar_path
  layer_name          = "generic_stuff_layer"
  compatible_runtimes = [
    local.runtime]
  source_code_hash    = filebase64sha256(local.layer_jar_path)
}

//************************************************
//INFLUENCE_ANALYSIS_LAMBDA:
//************************************************
resource "aws_lambda_function" "influenceAnalysisLambda" {
  function_name = "${var.resource_prefix}-influenceAnalysisLambda"
  handler       = "index.handler"
  role          = aws_iam_role.influence-analysis-role.arn
  runtime       = local.runtime

  filename         = local.lambda_jar_path
  source_code_hash = filebase64sha256(local.lambda_jar_path)

  timeout     = 30
  memory_size = local.lambda_memory
  layers      = [
    aws_lambda_layer_version.generic_stuff_layer.arn]

  vpc_config {
    subnet_ids         = [
      aws_subnet.redis_subnet.id]
    security_group_ids = [
      aws_security_group.redis_sg.id]
  }

  environment {
    variables = {
      LOG_LEVEL = var.log_level
      REDIS_URL = "redis://${aws_elasticache_cluster.redis.cache_nodes.0.address}:${aws_elasticache_cluster.redis.cache_nodes.0.port}"
    }
  }
}
