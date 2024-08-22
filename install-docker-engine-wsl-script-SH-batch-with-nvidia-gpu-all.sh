#!/bin/bash

# Remove existing Docker packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

# Update system packages
sudo apt-get update

# Install necessary packages
sudo apt-get install -y ca-certificates curl

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to Apt sources
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update system packages again
sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Test Docker installation
sudo docker run hello-world

# Post installation steps
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

# Create Docker volume
docker volume create hello

# Test Docker volume
docker run -d -v hello:/world busybox ls /world

# Create Docker volume with specific options
docker volume create --driver local --opt type=none --opt device=/mnt/c/Users/username/Documents/docker_directory  --opt o=bind docker_directory

# Install Nvidia container toolkit
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
    && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
        sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
        sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update

sudo apt-get install -y nvidia-container-toolkit

# Configure Nvidia container toolkit
sudo nvidia-ctk runtime configure --runtime=docker

# Restart Docker
sudo systemctl restart docker

# Configure Nvidia container toolkit with user config
nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json

# Restart Docker again
sudo systemctl  restart docker

# Configure Nvidia container toolkit
sudo nvidia-ctk config --set nvidia-container-cli.no-cgroups --in-place

# Configure Nvidia container toolkit for containerd and crio
sudo nvidia-ctk runtime configure --runtime=containerd
sudo systemctl restart containerd

sudo nvidia-ctk runtime configure --runtime=crio
sudo systemctl restart crio

# Create Docker volume with specific options again
docker volume create --driver local --opt type=none --opt device=/mnt/c/Users/username/Documents/docker_directory  --opt o=bind docker_directory

# test Nvidia container toolkit
sudo docker run --rm --runtime=nvidia --gpus all --privileged ubuntu nvidia-smi

# podman run --rm --security-opt=label=disable \
   --device=nvidia.com/gpu=all \
   ubuntu nvidia-smi

