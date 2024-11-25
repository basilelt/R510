#!/bin/bash

# Set the environment variable to prevent interactive prompts
export DEBIAN_FRONTEND=noninteractive
exec < /dev/null

# Update the package index and install required dependencies
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index (again)
sudo apt-get update

# Install Docker Engine, containerd, and Docker Compose
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the current user to the docker group to run Docker without sudo
sudo usermod -aG docker vagrant

# Start and enable the Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Print the Docker version to verify the installation
docker --version

echo "Docker has been successfully installed and configured."
echo "Please log out and log back in for the group changes to take effect."