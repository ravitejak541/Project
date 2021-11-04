locals {
  private_key = file("${path.module}/rsa-pemkey")
  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks  = "0.0.0.0/0"
      description = "SSH Rule"
    },
    {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks  = "172.29.0.0/16"
      description = "MongoDB Rule"
    }
  ]
  egress_rules = [
    {
         from_port   = 0
         to_port     = 0
         protocol    = "-1"
         cidr_blocks = "0.0.0.0/0"
      }
  ]
}


module "mongo_vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  name                   = "mongo_vpc"
  cidr                   = "172.29.0.0/16"
  azs                    = ["ca-central-1a", "ca-central-1b"]
  private_subnets        = ["172.29.1.0/24", "172.29.2.0/24"]
  public_subnets         = ["172.29.4.0/24", "172.29.5.0/24"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  tags = {
    Environment = "dev"
  }
  manage_default_security_group  = true
  default_security_group_ingress = local.ingress_rules
  default_security_group_egress = local.egress_rules
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.keypair_name
  public_key = file("rsa-pemkey.pub")
}

module "mongo_ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  for_each               = toset(["mongo-001", "mongo-002", "mongo-003"])
  name                   = "instance-${each.key}"
  ami                    = "ami-0e28822503eeedddc"
  availability_zone      = element(module.mongo_vpc.azs, 0)
  subnet_id              = element(module.mongo_vpc.private_subnets, 0)
  instance_type          = "t3a.medium"
  key_name               = var.keypair_name
  vpc_security_group_ids = [module.mongo_vpc.default_security_group_id]

  tags = {
    Environment = "dev"
  }

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 100
    }
  ]
}

module "bastion_ec2_instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  for_each               = toset(["bastion"])
  name                   = "instance-${each.key}"
  ami                    = "ami-0e28822503eeedddc"
  availability_zone      = element(module.mongo_vpc.azs, 0)
  subnet_id              = element(module.mongo_vpc.public_subnets, 0)
  instance_type          = "t3a.medium"
  key_name               = var.keypair_name
  vpc_security_group_ids = [module.mongo_vpc.default_security_group_id]

  tags = {
    Environment = "dev"
  }

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 15
    }
  ]
}
