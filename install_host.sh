#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

function cleanup() {
    echo "Cleaning up..."
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    # Update the package index and uninstall old docker packages
    sudo apt-get update
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

    # Add Hashicorp's GPG key and repository
    wget -O- https://apt-get.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt-get.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    # Add Debian Fasttrack's GPG key and repository
    sudo apt-get install -y fasttrack-archive-keyring
    echo "deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-fasttrack main contrib" | sudo tee /etc/apt/sources.list.d/fasttrack.list
    echo "deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-backports-staging main contrib" | sudo tee /etc/apt/sources.list.d/backports.list
    
    sudo apt-get install -y ca-certificates \
                    curl \
                    gnupg

    # Add Docker's GPG key and repository
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up the Docker repository
    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
    # Update the package index
    sudo apt-get update

    # Install Docker Engine, containerd, and Docker Compose
    sudo apt-get install -y docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin \
                vagrant \
                virtualbox \
                virtualbox-ext-pack
    
    #vagrant plugin install vagrant-triggers
    
    # Enable and start the Docker service
    sudo systemctl enable docker
    sudo systemctl start docker

    # Download and install Docker Desktop
    wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.22.0-amd64.deb
    sudo apt-get install ./docker-desktop-4.22.0-amd64.deb
    rm docker-desktop-4.22.0-amd64.deb

    # Add the current user to the docker group
    sudo usermod -aG docker $USER

    # Upgrade packages
    sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y && sudo apt-get clean
fi