locals {
  lambda_handler       = format("%s.lambda_handler", var.lambda_name)
  requirements_txt     = format("%s/requirements.txt", var.lambda_source)
  cloudwatch_log_group = format("/aws/lambda/%s", var.lambda_name)
  arn_policy_string    = join("~", var.policy_arn)
}

resource "random_uuid" "lambda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(var.lambda_source, "*.py"),
      fileset(var.lambda_source, "requirements.txt"),
    ) :
    filename => filemd5(format("%s/%s", var.lambda_source, filename))
  }
}

# Creating a Python venv and install dependencies
resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = <<EOT
        cd ${var.lambda_source};
        python -m venv .venv;
        ./.venv/scripts/activate;
        pip install -r requirements.txt -t .;
        ./.venv/scripts/deactivate;
      EOT

    interpreter = ["powershell", "-Command"]
  }


  triggers = {
    source_code_hash = random_uuid.lambda_src_hash.result 
  }

}

# Zipping the Python src files
data "archive_file" "lambda_source_package" {
  type        = "zip"
  source_dir  = var.lambda_source
  output_path = format("%s/.tmp/%s.zip", path.module, random_uuid.lambda_src_hash.result)

  excludes = [
    ".venv"
  ]

  depends_on = [null_resource.install_dependencies]
}


data "aws_iam_role" "iam_for_lambda" {
  name = var.iam_role_name
}

# Creation of AWS Lambda and definition of necessary fields
resource "aws_lambda_function" "lambda" {
  function_name    = var.lambda_name
  role             = data.aws_iam_role.iam_for_lambda.arn
  filename         = data.archive_file.lambda_source_package.output_path
  runtime          = var.python_runtime
  handler          = local.lambda_handler
  memory_size      = var.memory_size
  timeout          = var.timeout
  publish          = true
  source_code_hash = data.archive_file.lambda_source_package.output_base64sha256

  layers = var.layers

  environment {
    variables = {
      LOG_LEVEL = var.lambda_log_level
    }
  }

  lifecycle {
    ignore_changes = [environment]
  }

  depends_on = [
    aws_iam_role_policy_attachment.policies,
    aws_cloudwatch_log_group.lambda
  ]
}

# for logging and retention period
resource "aws_cloudwatch_log_group" "lambda" {
  name              = local.cloudwatch_log_group
  retention_in_days = var.log_retention_period
}

# Attaches specified IAM policies and role used by Lambda function
resource "aws_iam_role_policy_attachment" "policies" {
  role       = var.iam_role_name
  count      = length(var.policy_arn)
  policy_arn = trimspace(split("~", local.arn_policy_string)[count.index])
}
