#!/usr/bin/env bash
set -euxo pipefail

echo "Installing updates and pre-requisites...."
sudo yum -y check-update || true
sudo yum -y update
sudo yum install -q -y wget unzip bind-utils \
  ntp ca-certificates vim-enhanced

if ! systemctl is-enabled --quiet ntpd.service; then
  sudo systemctl enable ntpd.service
fi

if systemctl is-enabled --quiet firewalld; then
  sudo systemctl disable firewalld
fi

curl --silent -O https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install awscli

