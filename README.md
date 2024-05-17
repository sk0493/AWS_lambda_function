# Introduction

This deploys a Python script as a AWS Lambda function. 

I have included two ways of doing this:
- Using Terraform to automatically create and deploy the Python files as a AWS Lambda function (iac folder)
- "Manually" deploying by archiving the Python files and using the CLI to deploy as an AWS Lambda function. (See snippets.md at source)

# src Folder
lambda_function.py and requirements.txt are the requiered files for the Python function. 
I used a my git repository as a required dependency and module for efficiency. 

# IaC Method

At the IaC level. The Terraform configuration files and JSON files deploy the AWS Lambda function and configure its necessary setup and policies.

## JSON Policy Files

1. trust-policy.json
   This JSON file defines the trust policy for the Lambda's IAM role, allowing the Lambda service to assume this role. The effect is "Allow".
2. logging-policy.json
   This JSON file sets up permissions for logging, allowing the Lambda function to create log groups, create log streams, and put log events (CloudWatch)

## Terraform Files Inside "IaC" Folder 

- Configuration of AWS provider
- Definition of necessary variables for deployment
- Creation of Lambda function using a module (see below), IAM role and attaching the policies (based from JSON files)

## Lambda Function Module 

This automates the deployment of an AWS Lambda function, including packaging the source code, managing dependencies, setting up the necessary IAM roles and policies, creating a CloudWatch log group, and outputting relevant information about the deployed Lambda function. The use of providers, local variables, and resources ensures that the deployment is efficient, repeatable, and maintainable.

# CLI and Manual Archiving Method

List of all commands and steps to deploy as a lambda function

- install aws cli:
  `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi`
  `aws --version`

- Authenticate to aws:
  `aws configure`
  xml output : json

- Create virtual environment:
  `python -m venv .venv`

- Activate virtual environment on Bash:
  `source .venv/Scripts/activate`

- Install dependencies:
  `pip install -r requirements.txt`

- Create venv zip folder on Powershell:
  `compress-archive -path ".venv/Lib/site-packages/*" -destinationPath "deployment.zip"`

- Update zip folder to have lambda_function.py file:
  `compress-archive -update .\lambda_function.py deployment.zip`

- Deploy to AWS via cli:
  `aws lambda update-function-code --function-name sixdegreeskb-sk --zip-file fileb://deployment.zip`
