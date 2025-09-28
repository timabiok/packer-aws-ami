#!/bin/bash
# sudo exec > /opt/userdata.log 2>&1
set -e

# replace <region> with your region, e.g. us-east-1
sudo dnf install -y https://s3.amazonaws.com/amazon-ssm-${REGION}/latest/linux_amd64/amazon-ssm-agent.rpm

# enable and start
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

sudo dnf install -y python3-pip
python3 -m pip install --user ansible

# echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
# source ~/.bashrc

ansible --version