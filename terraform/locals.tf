locals {
  name = "influence-analysis"
  lambda_memory = 512
  runtime = "java11"

  layer_jar_path = "${path.module}/../lambda/influence-analysis/layer/build/libs/layer.jar"
  //  layer_jar_path = "${path.module}/../lambda/influence-analysis/lambda/build/distributions/lambda.zip"
  //  lambda_jar_path = "${path.module}/../lambda/influence-analysis/lambda/build/libs/lambda.jar"
  lambda_jar_path = "${path.module}/../lambda/influence-analysis/lambda/build/distributions/lambda.zip"

  tags = {
    Name = "influence-analysis"
    GitRepo = "https://github.com/palerique/influence-analysis"
  }
}
