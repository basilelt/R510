#!/bin/bash

docker secret create mysql_password config/mysql_password.secret
docker secret create mysql_root_password config/mysql_root_password.secret

docker config create django_config config/settings.py
docker config create proxy_conf config/proxy.conf
