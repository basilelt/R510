#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

function cleanup() {
    echo "Cleaning up..."
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    sudo apt update
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove $pkg; done

    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt install -y fasttrack-archive-keyring
    echo "deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-fasttrack main contrib" | sudo tee /etc/apt/sources.list.d/fasttrack.list
    echo "deb https://fasttrack.debian.net/debian-fasttrack/ bookworm-backports-staging main contrib" | sudo tee /etc/apt/sources.list.d/backports.list
    
    sudo apt install -y ca-certificates \
                    curl \
                    gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
    sudo apt update

    sudo apt install -y docker-ce \
                docker-ce-cli \
                containerd.io \
                docker-buildx-plugin \
                docker-compose-plugin \
                vagrant \
                virtualbox \
                virtualbox-ext-pack
    
    sudo systemctl enable docker
    sudo systemctl start docker

    wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.22.0-amd64.deb
    sudo apt install ./docker-desktop-4.22.0-amd64.deb
    rm docker-desktop-4.22.0-amd64.deb

    sudo usermod -aG docker $USER

    sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt clean
fi