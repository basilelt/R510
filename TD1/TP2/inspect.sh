#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

function cleanup() {
    echo "Cleaning up..."
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "Current directory (full path): $current_dir"
    cd "$current_dir"

    export DOCKER_HOST=unix:///Users/${USER}/.docker/run/docker.sock

    docker build -t tp2 .
    printf "\n\033[1;33m--HADOLINT--\033[0m\n"
    hadolint Dockerfile

    printf "\npress enter to continue\n"
    read -n 1
    printf "\n\033[1;33m--SCOUT--\033[0m\n"
    docker scout quickview tp2
    docker scout recommendations tp2

    printf "\npress enter to continue\n"
    read -n 1
    printf "\n\033[1;33m--TRIVY--\033[0m\n"
    trivy image tp2

    printf "\npress enter to continue\n"
    read -n 1
    printf "\n--DIVE--\n"
    dive tp2
fi