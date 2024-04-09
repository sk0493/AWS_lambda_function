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