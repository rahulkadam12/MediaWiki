# Deploying MediaWiki app into kubernetes

- In this automation we are going to create a Microk8s in a AWS VM and deploying a MediWiki into it using Terraform.

## Prerequisites

- Install Terraform and AWS cli on the VM.
- Export the ACCESS KEY and SECRET KEY of AWS as an environment variable or pass it during the run time.
- Install ruby and ruby json.

## To install Python

```
dnf install python3-pip
vi ~/.bash_profile
export PATH=~/.local/bin:$PATH

```
- Save the file and exit logout from root user and login back

## To install aws-cli

```
pip3 install awscli --upgrade -–user

```
- Configure aws as shown below 

```
aws configure (enter following Parameters)
AWS Access Key ID [None]: Your access Key
AWS Secret Access Key [None]: Your secret key
Default region name [None]: your region 
Default output format [None]: json

```
## To install Terraform

```

yum update -y
yum install wget -y
yum install git ruby ruby-json -y
wget https://releases.hashicorp.com/terraform/1.2.4/terraform_1.2.4_linux_amd64.zip
yum install unzip -y
sudo unzip ./terraform_1.2.4_linux_amd64.zip -d /usr/local/bin

```

## Running Automation

- Change directory to cd/opt
- Clone the Repository as shown below
```
git clone https://github.com/rahulkadam12/MediaWiki.git

```
- Switch to terraform Directory as shown below 

```
cd /Mediwiki/Terraform

```
- Generate ssh key using the command shown below you need to provide the same keyname file which we defined in Terraform main.tf as this will be used to connect the VM and install Microk8s on VM.
- After executing command it will create 2 files myappkey and myappkey.pub

```
ssh-keygen -f myappkey

```

- Run terraform commands as shown below

```
terraform init
terraform plan
terraform apply

```

- After terraform task is completed check your application by running on browser

```
http://{your public IP}:30101

```
