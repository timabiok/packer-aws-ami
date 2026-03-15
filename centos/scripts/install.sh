#!/bin/bash
set -euo pipefail

sudo dnf install -y "https://s3.amazonaws.com/amazon-ssm-${REGION}/latest/linux_amd64/amazon-ssm-agent.rpm"

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

sudo dnf install -y ansible-core

# Promtail and log exporter (Fluent Bit)
if ! rpm -q promtail &>/dev/null; then
  sudo dnf install -y promtail 2>/dev/null || true
  if ! rpm -q promtail &>/dev/null; then
    # Add Grafana RPM repo for Loki/Promtail
    sudo tee /etc/yum.repos.d/grafana.repo >/dev/null <<'REPO'
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
REPO
    sudo dnf install -y promtail 2>/dev/null || true
  fi
fi
if rpm -q promtail &>/dev/null; then
  sudo systemctl enable promtail
  sudo systemctl start promtail
fi

# Fluent Bit (log exporter) - try EPEL or upstream repo
sudo dnf install -y epel-release 2>/dev/null || true
sudo dnf install -y fluent-bit 2>/dev/null || true
if rpm -q fluent-bit &>/dev/null; then
  sudo systemctl enable fluent-bit
  sudo systemctl start fluent-bit
fi

# dnf-automatic: install, configure apply_updates=yes, enable
sudo dnf install -y dnf-automatic
if [[ -f /tmp/dnf-automatic.conf ]]; then
  sudo cp /tmp/dnf-automatic.conf /etc/dnf/automatic.conf
  rm -f /tmp/dnf-automatic.conf
else
  sudo cp /etc/dnf/automatic.conf /etc/dnf/automatic.conf.bak 2>/dev/null || true
  sudo tee /etc/dnf/automatic.conf >/dev/null <<'AUTOCONF'
[commands]
apply_updates = yes
download_updates = yes
upgrade_type = default

[emitters]
emit_via = stdio

[email]
email_from = root@localhost

[command_email]
command = /usr/bin/true

[command_apply_updates]
command = /usr/bin/true
AUTOCONF
fi
sudo systemctl enable dnf-automatic.timer
sudo systemctl start dnf-automatic.timer

ansible --version
