#!/bin/bash
# sudo exec > /opt/userdata.log 2>&1
set -e

# routine maintenance
sudo yum install -y -q --nogpgcheck tar util-linux wget zip unzip gcc which vim curl nano zsh jq
sudo yum install -y -q $JAVA_INSTALLER glibc* glibc.i686 libgcc rng-tools

PORTS=($(echo $JSON_PORTS | jq -r '.[]'))

# set sysctl.conf as per sn recommendation
sudo tee -a /etc/sysctl.d/99-sysctl.conf <<EOF
vm.swappiness=1
EOF

# set 20-nproc.conf as per sn recommendation
sudo tee -a /etc/security/limits.d/20-nproc.conf <<EOF
*          soft    nproc     10240
EOF

# set amb-sockets.conf as per sn recommendation
sudo tee -a /etc/security/limits.d/amb-sockets.conf <<EOF
*          soft    nofile     16000
*          hard    nofile     16000
EOF

# unset SELinux from enforcing per sn recommendation
sudo tee /etc/selinux/config <<EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF

sudo mkdir -p /tmp/glide/
sudo chmod 777 /tmp/glide/

# retrieving snow installation zip for s3
/usr/local/bin/aws s3 cp s3://$BUCKET/$KEY /tmp/glide/sn.zip

# installing snow
sudo useradd servicenow
SERVICE=""

for PORT in "${PORTS[@]}"; do

    sudo java -jar /tmp/glide/*.zip --dst-dir /glide/nodes/sn_$PORT install -n sn -p $PORT
    sudo chown -R servicenow:servicenow /glide/nodes/sn_$PORT

    # Check if the number is less than 10
    if [ $PORT -eq 8443 ]; then
        SERVICE="servicenow.service"
        echo "Building ServiceNow UI NODE Service $SERVICE @ $PORT"
    elif [ $PORT -eq 9443 ]; then
        SERVICE="worker.service"
        echo "Building ServiceNow WORKER NODE Service $SERVICE @ $PORT"
    fi

    echo "completed glide script"
    sudo touch /etc/systemd/system/$SERVICE

    sudo tee /etc/systemd/system/$SERVICE <<EOF
# ServiceNow SystemD start/stop script
[Unit]
Description=ServiceNow Tomcat Container
After=syslog.target

[Service]
Type=forking
Environment="JAVA_HOME=/usr
ExecStart=/glide/nodes/sn_$PORT/startup.sh
ExecStop=/glide/nodes/sn_$PORT/shutdown.sh
User=servicenow
Group=servicenow
UMask=0007
LimitNOFILE=16000
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE

done

sudo yum clean all && rm /tmp/glide/*.zip
