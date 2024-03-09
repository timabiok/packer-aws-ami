#!/bin/bash
# sudo exec > /opt/userdata.log 2>&1

echo "started glide script with vars BUCKET=${BUCKET}, JAVA_INSTALLER=${JAVA_INSTALLER} and PORT=${PORT}"

# routine maintenance
# sudo yum update -y -q
sudo yum install -y -q --nogpgcheck tar util-linux wget zip unzip gcc which vim curl nano zsh
sudo yum install -y -q ${JAVA_INSTALLER} glibc* glibc.i686 libgcc rng-tools

# set sysctl.conf as per sn recommendation
sudo tee -a /etc/sysctl.d/99-sysctl.conf << EOF
vm.swappiness=1
EOF

# set 20-nproc.conf as per sn recommendation
sudo tee -a /etc/security/limits.d/20-nproc.conf << EOF
*          soft    nproc     10240
EOF

# set amb-sockets.conf as per sn recommendation
sudo tee -a /etc/security/limits.d/amb-sockets.conf << EOF
*          soft    nofile     16000
*          hard    nofile     16000
EOF

# unset SELinux from enforcing per sn recommendation
sudo tee /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF

sudo mkdir -p /tmp/glide/
sudo chmod 777 /tmp/glide/


# retrieving snow installation zip for s3
/usr/local/bin/aws s3 cp s3://${BUCKET}/${KEY} /tmp/glide/sn.zip \

# installing snow
sudo useradd servicenow 
sudo java -jar /tmp/glide/*.zip --dst-dir /glide/nodes/sn_${PORT} install -n sn -p ${PORT}
sudo chown -R servicenow:servicenow /glide/nodes/sn_${PORT} 
sudo yum clean all && rm /tmp/glide/*.zip

echo "completed glide script"

sudo touch /etc/systemd/system/glide.service

sudo tee /etc/systemd/system/glide.service << EOF
# ServiceNow SystemD start/stop script
[Unit]
Description=ServiceNow Tomcat Container
After=syslog.target

[Service]
Type=forking
Environment="JAVA_HOME=/usr
ExecStart=/glide/nodes/sn_${PORT}/startup.sh
ExecStop=/glide/nodes/sn_${PORT}/shutdown.sh
User=servicenow
Group=servicenow
UMask=0007
LimitNOFILE=16000
Restart=always

[Install]
WantedBy=multi-user.target
EOF


# sudo -s 'cat << EOF > /glide/nodes/${PORT}/conf/glide.db.properties'
# glide.db.name = sn_${PORT}
# glide.db.rdbms = mysql
# glide.db.url = jdbc:mysql://myinstance.123456789012.us-west-2.rds.amazonaws.com/
# glide.db.user = sn
# glide.db.password = snow1234
# EOF

# sudo -s 'cat << EOF > /glide/nodes/sn_${PORT}/conf/glide.properties'
# glide.proxy.host = http:example.com
# glide.proxy.path = /
# glide.servlet.port = ${PORT}

# # SEMAPHORES-WORKERS-DATABASE
# glide.db.pooler.connections = 32
# glide.db.pooler.connections.max = 32
# glide.sys.schedulers = 8

# # OTHER RECOMMENDED PROPS
# glide.monitor.url = localhost
# glide.self.monitor.fast_stats = false
# glide.self.monitor.checkin.interval = 86400000
# glide.self.monitor.server_stats.interval = 86400000
# glide.self.monitor.fast_server_stats.interval = 86400000
# EOF

sudo systemctl daemon-reload
sudo systemctl enable glide.service

# To ensure service is started upon server reboot, create softlink similar to the following:
# ln -s /etc/systemd/system/glide.service /etc/systemd/system/multi-user.target.wants/glide.service

# Once all these steps are complete, test by rebooting the server to ensure ServiceNowstarts automatically.

# export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.312.b07-1.el7_9.x86_64 && \
# cd /glide/nodes/${node}/ && \
# sudo ./tlog.sh

