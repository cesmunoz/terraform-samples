#################################################################
# DESCRIPTION OF FILE
#################################################################

# In this example we are trying to connect to AWS and create an
# EC2 Instance (Virtual Machine). When its running we tell in the
# terraform file to connect to the instance and install and run
# nginx. Finally it will give us the public-dns to see the nginx 
# running
# We also make uso of variable in a different file

# Important
# We need to modify the default security group in the EC2 section
# SSH 22 and HTTP 80

#################################################################
# VARIABLES 
#################################################################

variable aws_access_key {}
variable aws_secret_key {}
variable aws_private_key {}
variable key_name {
    default = "aws-example"
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

resource "aws_instance" "nginx" {
    ami           = "ami-97785bed"
    instance_type = "t2.micro"
    key_name      = "${var.key_name}" 

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