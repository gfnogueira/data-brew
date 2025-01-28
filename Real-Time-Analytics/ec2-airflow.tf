locals {
  airflow-machine = {
    instance_type           = "t3a.medium"
    root_volume_size        = "30"
    root_volume_type        = "gp3"
    ami_id                  = "ami-079cb33ef719a7b78"
    backup_dlm              = "weekly"
    disable_api_termination = "true"
  }
  airflow-component = {
    name                = "airflow"
    public_instance     = true
    public_instance_eip = false
  }
}

module "key_pair_airflow" {

  source = "./modules/aws/keypair"

  key_name = format("%s-%s", local.organization_account_name, local.airflow-component.name)
  account  = local.organization_name
}

module "ec2_airflow" {
  source                  = "./modules/aws/ec2"
  name                    = format("%s-%s", local.organization_name, local.airflow-component.name)
  environment             = local.account_name
  ami                     = local.airflow-machine.ami_id
  #ami                     = data.aws_ami.ubuntu-24-04.id
  key_name                = module.key_pair_airflow.key_pair_key_name
  policy                  = module.iam_airflow.policy_id
  instance_type           = local.airflow-machine.instance_type
  volume_size             = local.airflow-machine.root_volume_size
  volume_type             = local.airflow-machine.root_volume_type
  vpc_security_group_ids  = [aws_security_group.sg_infra_airflow.id]
  snapshot                = local.airflow-machine.backup_dlm
  disable_api_termination = local.airflow-machine.disable_api_termination
  subnets                 = module.vpc.public_subnets
  public_instance         = local.airflow-component.public_instance
  public_instance_eip     = local.airflow-component.public_instance_eip
  iam_instance_profile    = module.iam_airflow.profile_name
  userdata                = "files/airflow-userdata.sh"

  depends_on = [
    module.key_pair_airflow,
    module.iam_airflow,
    aws_security_group.sg_infra_airflow
  ]
}
