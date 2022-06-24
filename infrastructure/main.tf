// AWS IAM Role

resource "aws_iam_role" "ddc_aws_iam_role" {
  name = "ddc-aws-iam-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "ddc-aws-iam-role"
  }
}

// AWS IAM Policy

resource "aws_iam_policy" "ddc_aws_iam_policy" {
  name        = "ddc_aws_iam_policy"
  path        = "/"
  description = "ddc_aws_iam_policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = "s3:GetObject",
        Effect = "Allow",
        Resource = join("", ["arn:aws:s3:::", var.arbitrary_terraform_state_files_bucket, "/*"])
      }
    ]
  })
}

// AWS IAM Role Policy Attachement

resource "aws_iam_role_policy_attachment" "ddc_aws_iam_role_policy_attachment" {
  role       = aws_iam_role.ddc_aws_iam_role.name
  policy_arn = aws_iam_policy.ddc_aws_iam_policy.arn
}

// AWS Lambda Fucntion 

resource "aws_lambda_function" "ddc_aws_lambda_function" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "../src/payload.zip"
  function_name = "ddc_aws_lambda_function"
  role          = aws_iam_role.ddc_aws_iam_role.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../src/payload.zip")

  runtime = "python3.9"
}
