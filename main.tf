terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "My-Kubernetes-Test"

    workspaces {
      name = "My-Terraform-AWS"
    }
  }
}


# Create A VPC 
resource "aws_vpc" "main_vpc" {
    cidr_block          =   "${var.VPC_CIDR}"
    instance_tenancy    =   "default"
    tags                = {
        Name            = "${var.app_name}-vpc"
    }
}

# Create IGW for Public Access 
resource "aws_internet_gateway" "gw" {
    vpc_id              = "${aws_vpc.main_vpc.id}"
    tags                = {
        Name            = "${var.app_name}-igw"
  }
}

#Creating one public subnet
resource "aws_subnet" "public-subnets" {

    vpc_id                      = "${aws_vpc.main_vpc.id}"
    cidr_block                  = "10.10.1.0/24"
    map_public_ip_on_launch     = true

    tags = {
        Name                    = "public subnet"
  }
}


# Create Route  for Public Subnet
resource "aws_route_table" "public-rt" {
    vpc_id                      = "${aws_vpc.main_vpc.id}"

    route {
      cidr_block                = "0.0.0.0/0"
      gateway_id                = "${aws_internet_gateway.gw.id}"
    }

    tags                        = {
        Name                    = "${var.app_name}-Public-RT"
    }
}



## Associate Public-Route table to Public Subnet
resource "aws_route_table_association" "public-assoc" {

    subnet_id                   = "${aws_subnet.public-subnets.id}"
    route_table_id              = "${aws_route_table.public-rt.id}"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "ssh-sg" {
    name                        = "allow-ssh-external"
    description                 = "Allow SSH Access External"
    vpc_id                      = "${aws_vpc.main_vpc.id}"

    ingress {
      from_port                 = 22
      to_port                   = 22
      protocol                  = "TCP"
      cidr_blocks               = ["0.0.0.0/0"]
    }

    egress {
      from_port                 = 0
      to_port                   = 0
      protocol                  = "-1"
      cidr_blocks               = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "nodeport" {
    name                        = "allow-service"
    description                 = "Allow the service to be accessed"
    vpc_id                      = "${aws_vpc.main_vpc.id}"

    ingress {
      from_port                 = 30100
      to_port                   = 30100
      protocol                  = "TCP"
      cidr_blocks               = ["0.0.0.0/0"]
    }

    egress {
      from_port                 = 0
      to_port                   = 0
      protocol                  = "-1"
      cidr_blocks               = ["0.0.0.0/0"]
    }
}

resource "null_resource" "make-ssh-keys" {
    provisioner "local-exec" {
        command                 = "yes y | ssh-keygen -q -t rsa -f wikimedia -N ''"
    }

}
module "pem_content" {
  source                        = "matti/outputs/shell"
  command                       = "cat wikimedia"
}

### Get PUB Content
module "pub_content" {
  source                        = "matti/outputs/shell"
  command                       = "cat wikimedia.pub"
}

resource "aws_key_pair" "wikimedia" {
  key_name                      = "wikimedia"
  public_key                    = "${module.pub_content.stdout}"
}

#resource "aws_key_pair" "myappkey" {
#  key_name   = "myappkey"
#  public_key = file(var.PATH_TO_PUBLIC_KEY)
#}

resource "aws_instance" "web" {
  count                         = 1
  ami                           = "ami-052efd3df9dad4825"
  instance_type                 = "t2.large"
  key_name                      = aws_key_pair.wikimedia.key_name
  vpc_security_group_ids        = ["${aws_security_group.allow_http.id}","${aws_security_group.ssh-sg.id}","${aws_security_group.nodeport.id}"]
  subnet_id                     = "${aws_subnet.public-subnets.id}"

  tags                          = {
      Name                      = "${var.app_name}-node"
  }
  root_block_device {
  volume_size = "50"
    }
  
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"

  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh",
    ]
  }
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.INSTANCE_USERNAME
    private_key = file("wikimedia")
  }
}