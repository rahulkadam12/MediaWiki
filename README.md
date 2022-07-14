# Deploying MediaWiki app into kubernetes

- In this automation we are going to create a Microk8s in a AWS VM and deploying a MediWiki into it using Terraform.

## Prerequisites

- Install Terraform and AWS cli on the VM.
- Export the ACCESS KEY and SECRET KEY of AWS as an environment variable or pass it during the run time.
- Install ruby and ruby json.

```
yum install git ruby ruby-json -y
wget https://releases.hashicorp.com/terraform/0.12.6/terraform_0.12.6_linux_amd64.zip
sudo unzip ./terraform_0.11.13_linux_amd64.zip -d /bin/

```

