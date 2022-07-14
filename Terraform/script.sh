#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install Docker & Packages necessary for MiniKube Installation

sudo apt-get update -y
sudo apt-get install docker.io -y
sudo apt-get install -y conntrack

# install MiniKube

sudo wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

# install Kubectl

curl -LO https://storage.googleapis.com/kubernetes-release/release/(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# make sure nginx is started
service nginx start