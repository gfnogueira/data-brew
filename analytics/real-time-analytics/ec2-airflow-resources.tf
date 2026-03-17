module "iam_airflow" {
  source       = "./modules/aws/ec2/iam"
  role_name    = local.airflow-component.name
  account_id   = data.aws_ssm_parameter.account_id["nogueira_account"].value
  dlm_role_arn = format("arn:aws:iam::%s:role/AWSDataLifecycleManagerDefaultRole", data.aws_ssm_parameter.account_id["nogueira_account"].value)
  allow_resources_actions = [
    "autoscaling:*",
    "route53domains:*",
    "cloudfront:ListDistributions",
    "elasticloadbalancing:DescribeLoadBalancers",
    "elasticbeanstalk:DescribeEnvironments",
    "cloudwatch:DescribeAlarms",
    "cloudwatch:GetMetricStatistics",
    "logs:CreateLogStream",
    "logs:PutLogEvents",
    "iam:GetRole",
    "iam:PassRole",
    "dlm:*",
    "s3:*"
  ]
  deny_resources_actions = [
    "s3:DeleteBucket"
  ]
  dlm_resources_actions = [
    "iam:PassRole",
    "iam:ListRoles"
  ]
}
