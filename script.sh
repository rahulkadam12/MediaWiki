#!/bin/bash

#sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# Update Packages and Install snapd

sudo apt-get update -y
sudo apt install snapd -y

# Sleep for 30 seconds

sleep 30

# Install MicroKube 

sudo snap install microk8s --classic

# sleep for 45 seconds

sleep 45

# Check the status of Microk8s service

microk8s status --wait-ready
sleep 20

# Cloning Git Repository and changing Directory
cd /opt
sudo git clone https://github.com/rahulkadam12/MediaWiki.git && cd MediaWiki && cd Kubernetes

# Creating pods using Kubectl commands for secrets, PV, Mariadb and Mediawiki deployment

sudo microk8s kubectl create -f mariadb-secrets.yaml
sudo microk8s kubectl create -f persistent-volumes.yaml
sudo microk8s kubectl create -f mariadb-deployment.yaml
sudo microk8s kubectl create -f mariadb-svc.yaml
sudo microk8s kubectl create -f mediawikiapp-deployment.yaml
sudo microk8s kubectl create -f mediawiki-svc.yaml
sleep 10
sudo microk8s kubectl get pods