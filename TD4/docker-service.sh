#!/bin/bash

# Build the custom nginx image
docker build -t nginx-custom /home/vagrant/config

# Create the registry service (only on manager nodes)
docker service create --name registry \
    --publish published=5000,target=5000 \
    --constraint 'node.role==manager' \
    --restart-condition on-failure \
    registry:2.8

# Wait for the registry service to be ready
echo "Waiting for registry service to be ready..."
for i in {1..30}; do
    if curl -s http://192.168.56.101:5000/v2/ > /dev/null; then
        echo "Registry service is ready."
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Registry service failed to start. Exiting."
        exit 1
    fi
    sleep 5
done

# Cached apache2 image
docker tag httpd:latest 192.168.56.101:5000/httpd:latest
docker push 192.168.56.101:5000/httpd:latest

# Cached mysql image
docker tag mysql:latest 192.168.56.101:5000/mysql:latest
docker push 192.168.56.101:5000/mysql:latest

docker build -t 192.168.56.101:5000/django-custom:latest /home/vagrant/config
docker push 192.168.56.101:5000/django-custom:latest

# Cached traefik image
docker tag traefik:v2.10 192.168.56.101:5000/traefik:v2.10
docker push 192.168.56.101:5000/traefik:v2.10

# Run the docker-compose file as service
docker stack deploy --compose-file docker-compose.yml my_stack

echo "All services are up and running."