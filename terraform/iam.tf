resource "aws_iam_role" "influence-analysis-role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "influence-analysis-role" {
  policy_arn = aws_iam_policy.influence-analysis-role.arn
  role = aws_iam_role.influence-analysis-role.name
}

resource "aws_iam_policy" "influence-analysis-role" {
  policy = data.aws_iam_policy_document.influence-analysis-role.json
}

data "aws_iam_policy_document" "influence-analysis-role" {
  statement {
    sid = "AllowInvokingLambdas"
    effect = "Allow"
    resources = [
      "arn:aws:lambda:us-east-1:*:function:*"]
    actions = [
      "lambda:InvokeFunction"]
  }

  statement {
    sid = "AllowCreatingLogGroups"
    effect = "Allow"
    resources = [
      "arn:aws:logs:us-east-1:*:*"]
    actions = [
      "logs:CreateLogGroup"]
  }

  statement {
    sid = "AllowWritingLogs"
    effect = "Allow"
    resources = [
      "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    sid = "AllowIAMPassRole"
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "iam:*",
      "iam:PassRole",
      "organizations:DescribeAccount",
      "organizations:DescribeOrganization",
      "organizations:DescribeOrganizationalUnit",
      "organizations:DescribePolicy",
      "organizations:ListChildren",
      "organizations:ListParents",
      "organizations:ListPoliciesForTarget",
      "organizations:ListRoots",
      "organizations:ListPolicies",
      "organizations:ListTargetsForPolicy"
    ]
  }
}

//resource "aws_iam_role" "lambda-vpc-role" {
//  name               = var.function_name
//  assume_role_policy = data.aws_iam_policy_document.assume_role.json
//}

# Attach an additional policy to Lambda function IAM role required for the VPC config
data "aws_iam_policy_document" "network" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "network" {
  //  count  = 1
  name = "influence-analysis-network"
  policy = data.aws_iam_policy_document.network.json
}

resource "aws_iam_policy_attachment" "network" {
  //  count      = 1
  name = "influence-analysis-network"
  roles = [
    aws_iam_role.influence-analysis-role.name]
  policy_arn = aws_iam_policy.network.arn
}
