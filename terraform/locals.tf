locals {
  name          = "influence-analysis"
  lambda_memory = 256
  runtime       = "java11"

  layer_jar_path  = "${path.module}/../lambda/influence-analysis-II/layer/build/libs/layer.jar"
  lambda_jar_path = "${path.module}/../lambda/influence-analysis-II/lambda/build/libs/lambda.jar"

  tags = {
    Name    = "influence-analysis"
    GitRepo = "https://github.com/palerique/influence-analysis"
  }
}
