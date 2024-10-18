#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

function cleanup() {
    echo "Cleaning up..."
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    docker secret create mysql_password mysql_password.secret
    docker secret create mysql_root_password mysql_root_password.secret
fi