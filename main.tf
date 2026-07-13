module "networking" {
  source                = "git::https://github.com/BPainemilla-IaC-Org/terraform-aws-vpc-module.git?ref=v1.0.0"
  vpc_name              = var.vpc_name
  vpc_cidr_block        = var.vpc_cidr_block
  subnet_a_name         = var.subnet_a_name
  subnet_a_cidr         = var.subnet_a_cidr
  subnet_a_az           = var.subnet_a_az
  subnet_b_name         = var.subnet_b_name
  subnet_b_cidr         = var.subnet_b_cidr
  subnet_b_az           = var.subnet_b_az
  internet_gateway_name = var.internet_gateway_name
  route_table_name      = var.route_table_name
  security_group_name   = var.security_group_name
  ssh_port              = var.ssh_port
  http_port             = var.http_port
  allowed_cidr_blocks   = var.allowed_cidr_blocks
}

module "compute" {
  source            = "git::https://github.com/BPainemilla-IaC-Org/terraform-aws-ec2-module.git?ref=v1.0.0"
  ssh_key_name      = var.ssh_key_name
  ssh_key_filename  = var.ssh_key_filename
  tls_key_bits      = var.tls_key_bits
  ec2_instance_name = var.ec2_instance_name
  ec2_instance_type = var.ec2_instance_type
  ami_owner         = var.ami_owner
  ami_name_filter   = var.ami_name_filter
  ssh_connect_user  = var.ssh_connect_user
  subnet_id         = module.networking.subnet_public_a_id
  # vpc_security_group_ids = [module.networking.security_group_id]
}

module "storage" {
  source                  = "git::https://github.com/BPainemilla-IaC-Org/terraform-aws-s3-module.git?ref=v1.0.0"
  s3_bucket_name          = var.s3_bucket_name
  s3_bucket_is_public     = var.s3_bucket_is_public
  s3_force_destroy        = var.s3_force_destroy
  s3_versioning_status    = var.s3_versioning_status
  s3_encryption_algorithm = var.s3_encryption_algorithm
}