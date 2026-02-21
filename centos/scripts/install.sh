#!/bin/bash
set -euo pipefail

sudo dnf install -y "https://s3.amazonaws.com/amazon-ssm-${REGION}/latest/linux_amd64/amazon-ssm-agent.rpm"

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

sudo dnf install -y python3-pip
python3 -m pip install --user ansible

ansible --version
