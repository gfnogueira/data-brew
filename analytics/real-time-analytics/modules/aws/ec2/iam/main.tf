resource "aws_iam_role" "this" {
  name = "${var.role_name}-ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = {
    Name = var.role_name
  }
}

resource "aws_iam_policy" "this" {
  name        = "${var.role_name}-ec2-policy"
  description = "Policy for AWS EC2 roles"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = var.allow_resources_actions,
        Resource = "*"
      },
      {
        Effect   = "Deny",
        Action   = var.deny_resources_actions,
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}


resource "aws_iam_policy" "dlm_policy" {
  name        = "${var.role_name}-dlm-policy"
  description = "Policy for AWS DLM roles"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = var.dlm_resources_actions,
        Resource = [var.dlm_role_arn]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "dlm_policy" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.dlm_policy.arn
}


resource "aws_iam_instance_profile" "this" {
  name = "${var.role_name}-profile"
  role = aws_iam_role.this.name
}