terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_access_key
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.environment_prefix}-vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.subnet_cidr
    tags = {
      Name = "${var.environment_prefix}-subnet"
    }
}

# Create an Internet gateway
resource "aws_internet_gateway" "my_internate_gateway" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
      Name = "${var.environment_prefix}-internet-gateway"
    }
}

# Create a Route table
resource "aws_route_table" "my_route_table" {
    vpc_id = aws_vpc.my_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_internate_gateway.id
    }

    tags = {
      Name = "${var.environment_prefix}-route-table"
    }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id
  name = "${var.environment_prefix}-sg"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "${var.environment_prefix}-security-group"
  }
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  owners = [ "amazon" ]

  filter {
    name = "image-id"
    values = [ "ami-0cae6d6fe6048ca2c" ]
  }
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-deploy-key"
  public_key = tls_private_key.deployer.public_key_openssh
}

resource "aws_instance" "my_instance" {
    ami = data.aws_ami.latest_amazon_linux.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.my_subnet.id
    vpc_security_group_ids = [ aws_security_group.my_security_group.id ]
    associate_public_ip_address = true
    key_name = aws_key_pair.jenkins_key.key_name

    user_data = file("entry_script.sh")

    tags = {
      Name = "${var.environment_prefix}-instance"
    }
}

output "jenkins_private_key" {
  value     = tls_private_key.deployer.private_key_pem
  sensitive = false
}