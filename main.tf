provider "aws" {
  region = "us-east-1"
}
# MODULES BLOCK
module "infra" {
  source      = "./modules/infra/"
  vpc_cidr    = "172.16.0.0/16"
  az          = "us-east-1a"
  subnet_cidr = "172.16.10.0/24"
  environment = "Prod"
  owner       = "Avenga"
}
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "aws-module-bucket-46435134846413165"
  acl    = "private"
  versioning = {
    enabled = true
  }

}
# resource "aws_s3_bucket" "a" {
#   bucket = "my-tf-test-bucket-85687546754612321"
#   tags = {
#     Name        = "My bucket A"
#     Environment = "Prod"
#   }
# }
# resource "aws_s3_bucket" "b" {
#   bucket = "my-tf-test-bucket-85687546754648931"
#   tags = {
#     Name        = "My bucket B"
#     Environment = "Dev"
#   }
# }
# resource "aws_s3_bucket_acl" "a" {
#   bucket = aws_s3_bucket.a.id
#   acl    = "public-read"
# }
# resource "aws_s3_bucket_acl" "b" {
#   bucket = aws_s3_bucket.b.id
#   acl    = "private"
# }
locals {
  environment = "Prod"
  owner       = "Avenga"
  terraform   = "true"
}
locals {
  infra_tags = {
    Environment = local.environment
    Owner       = local.owner
    Terraform   = local.terraform
  }
}
data "http" "icanhazip" {
  url = "http://ipv4.icanhazip.com"
}
data "template_file" "userdata" {
  template = file("./scripts/cloud-init.yml")
  vars = {
    vpc_id = module.infra.vpc_id
  }
}
# data "template_file" "userdata" {
#   template = file("./scripts/userdata.sh")
#   vars = {
#     vpc_id = aws_vpc.my_vpc.id
#   }
# }
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

# resource "aws_vpc" "my_vpc" {
#   cidr_block           = "172.16.0.0/16"
#   tags                 = local.infra_tags
#   enable_dns_support   = true
#   enable_dns_hostnames = true
# }
# resource "aws_subnet" "my_subnet" {
#   vpc_id                  = aws_vpc.my_vpc.id
#   cidr_block              = "172.16.10.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true
# }
# resource "aws_internet_gateway" "my_ig" {
#   vpc_id = aws_vpc.my_vpc.id
#   tags   = local.infra_tags
# }
# resource "aws_route_table" "my_rt" {
#   vpc_id = aws_vpc.my_vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_ig.id
#   }
#   tags = local.infra_tags
# }
# resource "aws_route_table_association" "subnet-association" {
#   subnet_id      = aws_subnet.my_subnet.id
#   route_table_id = aws_route_table.my_rt.id
# }
resource "aws_instance" "server" {
  count                   = var.server_count
  disable_api_termination = var.termination_protection
  instance_type           = var.server_type
  ami                     = data.aws_ami.ubuntu.id
  vpc_security_group_ids  = [aws_security_group.server_sg.id]
  subnet_id               = module.infra.subnet_id
  secondary_private_ips   = var.secondary_ips_pri
  key_name                = aws_key_pair.server_key.key_name
  # connection {
  #   type        = "ssh"
  #   user        = "ubuntu"
  #   host        = self.public_ip
  #   private_key = file("server")
  # }
  # provisioner "file" {
  #   source      = "scripts/script.sh"
  #   destination = "/tmp/script.sh"
  # }
  # provisioner "remote-exec" {
  #   inline = [
  #     "echo \"Inline remote-exec. First command.\" >> /tmp/remote-exec.txt",
  #     "echo \"Inline remote-exec. Second command.\" >> /tmp/remote-exec.txt",
  #     "chmod +x /tmp/script.sh",
  #     "/tmp/script.sh >> /tmp/remote-exec.txt"
  #   ]
  # }
  user_data = data.template_file.userdata.rendered
  # provisioner "local-exec" {
  #   command    = "echo \"This provisioner run when server with IP ${self.private_ip} started\" >> local-exec.txt"
  #   on_failure = continue
  # }
  # provisioner "local-exec" {
  #   when       = destroy
  #   command    = "echo \"This provisioner run when server with IP ${self.private_ip} destroyed\" >> local-exec.txt"
  #   on_failure = continue
  # }
  tags = var.server_tags
}
resource "aws_security_group" "server_sg" {
  name        = "server_sg"
  description = "SSH and HTTP access"
  vpc_id      = module.infra.vpc_id
  ingress {
    description = "Webserver access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.icanhazip.response_body)}/32"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = local.infra_tags
}
resource "aws_key_pair" "server_key" {
  key_name   = "server"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDOHVFfQPQXjxSsEoExpGN1TSnuoljIZAh4oiyFIOe2CnzB43oKLQ8AhWEm+myj6KVLGi9TquCjWntkKb92sIKUoYKyyU61jiBv1yTXjp/kqRDGmgVK0s5cT8+LbTnprmWDxkU2XJpT5mOraFt8+MSGbPlbLWv8Hv+RYn6kWNf0g/q7WydFf4M/VixDanGXJBwby5Yq3qxofmF6jXZ8VOdiTW0mBnHLQZ/w5O3iYbg7ZhNs8iK5jYg8G5iVTI98/+D4y3QF9iOXBAEzfxWTjj6CljtIuHUFwKjzikU0z6kf1wMrV2eDY67QteVdMKFFJYhjWGx8aQks8ZLMO1xLdfQ6wJRNYU6lCTNbrTsO/tH89bXE03VMv7JCF+kKXGXyDDmDxvJtBljPSPEyth8OgkblLVKggrJtpSlbOjxyuKGuJrBRpACPgKBEH6zCGDiyLlWL/+W1Xo3Owjx0v9DNOvcIWmg+2LPJP26TfagrOR7a4Al4bXEHXIAfh7OMjhTMkJs= root@avenga"
}
# resource "aws_wafv2_ip_set" "firewall" {
#   for_each           = var.waf_ips
#   name               = each.value["name"]
#   description        = each.value["description"]
#   scope              = "REGIONAL"
#   ip_address_version = "IPV4"
#   addresses          = each.value["addresses"]
# }
#
# data "aws_s3_bucket" "remote-backend" {
#   bucket = "remote-backend-s3-85687546754612322"
# }
#
# data "aws_availability_zones" "available" {
#   state = "available"
#   filter {
#     name   = "zone-type"
#     values = ["availability-zone"]
#   }
# }
#

# data "aws_s3_bucket" "legacy_import" {
#   bucket = "website-origin-1564841523"
# }
