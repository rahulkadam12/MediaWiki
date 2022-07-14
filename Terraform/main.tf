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
      from_port                 = 8081
      to_port                   = 8081
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


## Make Dynamic SSH keys
resource "null_resource" "make-ssh-keys" {
    provisioner "local-exec" {
        command                 = "yes y | ssh-keygen -q -t rsa -f mykey -N ''"
    }

}
module "pem_content" {
  source                        = "matti/outputs/shell"
  command                       = "cat mykey"
}

### Get PUB Content
module "pub_content" {
  source                        = "matti/outputs/shell"
  command                       = "cat mykey.pub"
}

resource "aws_key_pair" "mykey" {
  key_name                      = "mykey"
  public_key                    = "${module.pub_content.stdout}"
}


resource "aws_instance" "web" {
  count                         = 1
  ami                           = "ami-052efd3df9dad4825"
  instance_type                 = "t2.large"
  key_name                      = "${aws_key_pair.mykey.key_name}"
  vpc_security_group_ids        = ["${aws_security_group.allow_http.id}","${aws_security_group.ssh-sg.id}","${aws_security_group.nodeport.id}"]
  subnet_id                     = "${aws_subnet.public-subnets.id}"

  tags                          = {
      Name                      = "${var.app_name}-node"
  }
  root_block_device {
  volume_size = "50"
    }
  provisioner "remote-exec" {
    connection {
      type                      = "ssh"
      user                      = "ubuntu"
      private_key               = "${file("mykey")}"
      host                      = "${element(aws_instance.web.*.public_ip,count.index)}"

    }

    inline                      = [
      "sudo apt-get update",
      "sudo apt install snapd",
      "sleep 30",
      "sudo snap install microk8s --classic"
      "sleep 30"
      "alias mkctl="microk8s kubectl"",
      "sleep 30",
      "sudo apt-get install git -y",
      "sudo git clone https://github.com/rahulkadam12/MediaWiki.git && cd MediaWiki && cd kubernetes && sudo kubectl create -f secrets.yaml -f persistent-volumes.yaml",
      "sudo kubectl create  -f mariadb-deployment.yaml -f mariadb-svc.yaml",
      "sudo kubectl create -f mediawikiapp-deployment.yaml -f mediawiki-svc.yaml"

    ]
  }

}
### Print Pem content 
output "pem_content" {
    value = "${module.pem_content.stdout}"
}