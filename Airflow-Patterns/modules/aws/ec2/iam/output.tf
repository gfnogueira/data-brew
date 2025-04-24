output "role_id" {
  value = aws_iam_role.this.id
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "policy_id" {
  value = aws_iam_policy.this.id
}

output "policy_arn" {
  value = aws_iam_policy.this.arn
}

output "profile_name" {
  value = aws_iam_instance_profile.this.name
}