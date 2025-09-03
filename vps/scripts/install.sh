#!/usr/bin/bash

# Update package list
sudo apt update
sudo apt upgrade -y

sudo apt install -y cron git htop eza ca-certificates curl wget nano fail2ban rclone sqlite3 zstd

# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install fastfetch
sudo curl -fsSL https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb -o /tmp/fastfetch.deb
sudo dpkg -i /tmp/fastfetch.deb
rm /tmp/fastfetch.deb

# Enable and start services
sudo systemctl enable fail2ban
sudo systemctl enable docker

sudo systemctl start fail2ban
sudo systemctl start docker
