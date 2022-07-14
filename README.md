# Deploying MediaWiki app into kubernetes

- In this automation we are going to create a Microk8s in a AWS VM and deploying a MediWiki into it using Terraform.

## Prerequisites

- Install Terraform and AWS cli on the VM.
- Export the ACCESS KEY and SECRET KEY of AWS as an environment variable or pass it during the run time.
- Install ruby and ruby json.

```
yum install git ruby ruby-json -y
wget https://releases.hashicorp.com/terraform/1.2.4/terraform_1.2.4_linux_amd64.zip
sudo unzip ./terraform_1.2.4_linux_amd64.zip -d /bin/

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
- Run terraform commands as shown below

```
terraform init
terraform plan
terraform apply

```

- After terraform task is completed check your application by running on browser

```
http://{your public IP}:30100

```