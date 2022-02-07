
locals {
  lambda_code_files              = "SearchUI"
  lambda_code_file_name_SearchUI = "Search_UI_lambda"
  lambda_code_file_name_NMC_VOL  = "get_volume_names"
  lambda_folder                  = "Search_UI_lambda"
  lambda_code_extension          = ".py"
  handler                        = "lambda_handler"
  resource_name_prefix           = "nasuni-labs"

}

resource "random_id" "unique_SearchUI_id" {
  byte_length = 2
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${local.lambda_folder}/"
  output_path = "${local.lambda_code_files}.zip"
}
################### START - Search_UI_lambda Lambda ####################################################

resource "aws_lambda_function" "lambda_function_search_es" {
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "${local.lambda_code_file_name_SearchUI}.${local.handler}"
  runtime          = var.runtime
  filename         = "${local.lambda_code_files}.zip"
  function_name    = "${local.resource_name_prefix}-${local.lambda_code_file_name_SearchUI}-${random_id.unique_SearchUI_id.dec}"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 20

  tags = {
    Name            = "${local.resource_name_prefix}-${local.lambda_code_file_name_SearchUI}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logging,
    aws_iam_role_policy_attachment.ESHttpPost_access,
    aws_iam_role_policy_attachment.GetSecretValue_access,
    aws_cloudwatch_log_group.lambda_log_group_search
  ]

}
################### END - Search_UI_lambda Lambda ####################################################

################### START - Get ES Volumes Lambda ####################################################

resource "aws_lambda_function" "lambda_function_get_es_volumes" {
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "${local.lambda_code_file_name_NMC_VOL}.${local.handler}"
  runtime          = var.runtime
  filename         = "${local.lambda_code_files}.zip"
  function_name    = "${local.resource_name_prefix}-${local.lambda_code_file_name_NMC_VOL}-${random_id.unique_SearchUI_id.dec}"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 20

  tags = {
    Name            = "${local.resource_name_prefix}-${local.lambda_code_file_name_NMC_VOL}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logging,
    aws_iam_role_policy_attachment.ESHttpPost_access,
    aws_iam_role_policy_attachment.GetSecretValue_access,
    aws_cloudwatch_log_group.lambda_log_group_volume
  ]

}
################### END - Get ES Volumes Lambda ####################################################

################### START - Lambda Role and Policies  ####################################################

resource "aws_iam_role" "lambda_exec_role" {
  name        = "${local.resource_name_prefix}-exec_role-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
  path        = "/"
  description = "Allows Lambda Function to call AWS services on your behalf."

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name            = "${local.resource_name_prefix}-exec-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
}

############## CloudWatch Integration for Search Lambda ######################
resource "aws_cloudwatch_log_group" "lambda_log_group_search" {
  name              = "/aws/lambda/${local.resource_name_prefix}-${local.lambda_code_file_name_SearchUI}-${random_id.unique_SearchUI_id.dec}"
  retention_in_days = 14

  tags = {
    Name            = "${local.resource_name_prefix}-lambda_log_group-${local.lambda_code_file_name_SearchUI}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
}

############## CloudWatch Integration for Volume Lambda ######################
resource "aws_cloudwatch_log_group" "lambda_log_group_volume" {
  name              = "/aws/lambda/${local.resource_name_prefix}-${local.lambda_code_file_name_NMC_VOL}-${random_id.unique_SearchUI_id.dec}"
  retention_in_days = 14

  tags = {
    Name            = "${local.resource_name_prefix}-lambda_log_group-${local.lambda_code_file_name_NMC_VOL}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
}


# AWS Lambda Basic Execution Role
resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.resource_name_prefix}-lambda_logging_policy-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = {
    Name            = "${local.resource_name_prefix}-lambda_logging_policy-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


############## IAM policy for accessing ElasticSearch Domain from a lambda ######################
resource "aws_iam_policy" "ESHttpPost_access" {
  name        = "${local.resource_name_prefix}-ESHttpPost_access_policy-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
  path        = "/"
  description = "IAM policy for accessing ElasticSearch Domain from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "es:ESHttpPost"
            ],
            "Resource": "*"
        }
    ]
}
EOF
  tags = {
    Name            = "${local.resource_name_prefix}-ESHttpPost_access_policy-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
}

resource "aws_iam_role_policy_attachment" "ESHttpPost_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ESHttpPost_access.arn
}

############## IAM policy for accessing Secret Manager from a lambda ######################
resource "aws_iam_policy" "GetSecretValue_access" {
  name        = "${local.resource_name_prefix}-GetSecretValue_access_policy-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
  path        = "/"
  description = "IAM policy for accessing secretmanager from a lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "${data.aws_secretsmanager_secret.admin_secret.arn}"
        }
    ]
}
EOF
  tags = {
    Name            = "${local.resource_name_prefix}-GetSecretValue_access_policy-${local.lambda_code_files}-${random_id.unique_SearchUI_id.dec}"
    Application     = "Nasuni Analytics Connector with Elasticsearch"
    Developer       = "Nasuni"
    PublicationType = "Nasuni Labs"
    Version         = "V 0.1"
  }
}

resource "aws_iam_role_policy_attachment" "GetSecretValue_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.GetSecretValue_access.arn
}

data "aws_secretsmanager_secret" "admin_secret" {
  name = var.admin_secret
}
data "aws_secretsmanager_secret_version" "admin_secret" {
  secret_id = data.aws_secretsmanager_secret.admin_secret.id
}

data "aws_iam_policy" "CloudWatchFullAccess" {
  arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "CloudWatchFullAccess" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = data.aws_iam_policy.CloudWatchFullAccess.arn
}

data "aws_iam_policy" "AmazonESFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonESFullAccess" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = data.aws_iam_policy.AmazonESFullAccess.arn
}


data "aws_iam_policy" "AmazonOpenSearchServiceFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceFullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonOpenSearchServiceFullAccess" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = data.aws_iam_policy.AmazonOpenSearchServiceFullAccess.arn
}

data "aws_iam_policy" "AmazonOpenSearchServiceReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonOpenSearchServiceReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonOpenSearchServiceReadOnlyAccess" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = data.aws_iam_policy.AmazonOpenSearchServiceReadOnlyAccess.arn
}

################### END - Lambda Role and Policies  ####################################################


################### START - API Gateway setup for Lambda ####################################################


################### END - API Gateway setup for Lambda ####################################################


################### START - Deploy SearchUI Web  ####################################################


################### END - Deploy SearchUI Web ####################################################

