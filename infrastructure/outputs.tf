output "iam_role_arn" {
  description = "IAM Role ARN"
  value       = aws_iam_role.ddc_aws_iam_role.arn
}

output "iam_policy_arn" {
  description = "IAM Policy ARN"
  value       = aws_iam_policy.ddc_aws_iam_policy.arn
}

output "lambda_function_arn" {
  description = "Lambda Funciton ARN"
  value       = aws_lambda_function.ddc_aws_lambda_function.arn
}
