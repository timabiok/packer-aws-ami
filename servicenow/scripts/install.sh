#!/bin/bash
# sudo exec > /opt/userdata.log 2>&1
set -e

# replace <region> with your region, e.g. us-east-1
sudo dnf install -y https://s3.amazonaws.com/amazon-ssm-${REGION}/latest/linux_amd64/amazon-ssm-agent.rpm

# enable and start
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

sudo dnf install -y python3-pip
sudo python3 -m pip install --user ansible

# routine maintenance
# sudo yum install -y -q --nogpgcheck tar util-linux wget zip unzip gcc which vim curl nano zsh jq
# sudo yum install -y -q $JAVA_INSTALLER glibc* glibc.i686 libgcc rng-tools

# PORTS=($(echo $JSON_PORTS | jq -r '.[]'))

# # set sysctl.conf as per sn recommendation
# sudo tee -a /etc/sysctl.d/99-sysctl.conf <<EOF
# vm.swappiness=1
# EOF

# # set 20-nproc.conf as per sn recommendation
# sudo tee -a /etc/security/limits.d/20-nproc.conf <<EOF
# *          soft    nproc     10240
# EOF

# # set amb-sockets.conf as per sn recommendation
# sudo tee -a /etc/security/limits.d/amb-sockets.conf <<EOF
# *          soft    nofile     16000
# *          hard    nofile     16000
# EOF

# unset SELinux from enforcing per sn recommendation
# sudo tee /etc/selinux/config <<EOF
# SELINUX=permissive
# SELINUXTYPE=targeted
# EOF

sudo mkdir -p /opt/servicenow/
sudo chmod 777 /opt/servicenow/

# # retrieving snow installation zip for s3
# /usr/local/bin/aws s3 cp s3://$BUCKET/$KEY /opt/servicenow/sn.zip

# # installing snow
# sudo useradd servicenow
# SERVICE=""

# for PORT in "${PORTS[@]}"; do

#     sudo java -jar /opt/servicenow/*.zip --dst-dir /glide/nodes/sn_$PORT install -n sn -p $PORT
#     sudo chown -R servicenow:servicenow /glide/nodes/sn_$PORT

#     # Check if the number is less than 10
#     if [ $PORT -eq 8443 ]; then
#         SERVICE="servicenow.service"
#         echo "Building ServiceNow UI NODE Service $SERVICE @ $PORT"
#     elif [ $PORT -eq 9443 ]; then
#         SERVICE="worker.service"
#         echo "Building ServiceNow WORKER NODE Service $SERVICE @ $PORT"
#     fi

#     echo "completed glide script"
#     sudo touch /etc/systemd/system/$SERVICE

#     sudo tee /etc/systemd/system/$SERVICE <<EOF
# # ServiceNow SystemD start/stop script
# [Unit]
# Description=ServiceNow Tomcat Container
# After=syslog.target

# [Service]
# Type=forking
# Environment="JAVA_HOME=/usr
# ExecStart=/glide/nodes/sn_$PORT/startup.sh
# ExecStop=/glide/nodes/sn_$PORT/shutdown.sh
# User=servicenow
# Group=servicenow
# UMask=0007
# LimitNOFILE=16000
# Restart=always

# [Install]
# WantedBy=multi-user.target
# EOF

#     sudo systemctl daemon-reload
#     sudo systemctl enable $SERVICE
# done

# sudo yum clean all && rm /opt/servicenow/*.zip
