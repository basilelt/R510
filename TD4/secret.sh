#!/bin/bash

docker secret create postgres_password config/postgres_password.secret

docker config create django_config config/settings.py
docker config create proxy_conf config/proxy.conf
