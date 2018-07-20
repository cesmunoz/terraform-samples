#################################################################
# DESCRIPTION OF FILE
#################################################################

# In this example we are creating a VPC and Internet gateway and
# security group. The security group has all the necessary ports
# to connect thru ports: 80 (HTTP), 443 (HTTPS) and 22 (SSH)
# Create an EC2 and use the security group that we just created
# Install and run nginx in the EC2 Instance

#################################################################
# VARIABLES 
#################################################################

variable aws_access_key {}
variable aws_secret_key {}
variable aws_private_key {}

variable key_name {
  default = "aws-example"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

#################################################################
# PROVIDERS 
#################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

#################################################################
# RESOURCES
#################################################################

# VPC
resource "aws_vpc" "default" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags {
    Name = "aws-vpc-example"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Security Group
resource "aws_security_group" "aws-group-example" {
  name        = "aws-group-example"
  description = "Allow ssh-http inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh inbount traffic"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow http inbount traffic"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow https inbount traffic"
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ssh outbound traffic"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow http outbound traffic"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow https outbound traffic"
  }

  tags {
    Name = "aws-group-example"
  }
}

# EC2 Instance
resource "aws_instance" "nginx" {
  ami                    = "ami-97785bed"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.aws-group-example.id}"]

  connection {
    user        = "ec2-user"
    private_key = "${file(var.aws_private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
    ]
  }
}

#################################################################
# OUTPUT
#################################################################

output "aws_instance_public_dns" {
  value = "${aws_instance.nginx.public_dns}"
}
