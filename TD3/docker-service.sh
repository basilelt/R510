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

# Push the custom nginx image to the local registry
docker tag nginx-custom 192.168.56.101:5000/nginx-custom
docker push 192.168.56.101:5000/nginx-custom

# Create the overlay network
docker network create --driver=overlay traefik-public

# Create the Traefik service
docker service create \
    --name traefik \
    --constraint 'node.role==manager' \
    --publish published=80,target=80 \
    --publish published=8080,target=8080 \
    --publish published=443,target=443 \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
    --network traefik-public \
    --mode global \
    --restart-condition on-failure \
    traefik:v2.10 \
    --api.insecure=true \
    --providers.docker \
    --providers.docker.swarmMode \
    --providers.docker.exposedbydefault=false \
    --entrypoints.web.address=:80 \
    --entrypoints.websecure.address=:443

# Wait for Traefik to be ready
echo "Waiting for Traefik service to be ready..."
for i in {1..30}; do
    if docker service ls | grep -q "traefik.*1/1"; then
        echo "Traefik service is ready."
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Traefik service failed to start. Exiting."
        exit 1
    fi
    sleep 5
done

# Create the nginx service
docker service create \
    --name nginx-service \
    --replicas=3 \
    --network traefik-public \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.nginx.rule=Host(\`example.com\`)" \
    --label "traefik.http.services.nginx.loadbalancer.server.port=80" \
    --label "traefik.http.routers.nginx.entrypoints=web,websecure" \
    --restart-condition on-failure \
    192.168.56.101:5000/nginx-custom

# Wait for nginx service to be ready
echo "Waiting for nginx service to be ready..."
for i in {1..30}; do
    if docker service ls | grep -q "nginx-service.*3/3"; then
        echo "nginx service is ready."
        break
    fi
    if [ $i -eq 30 ]; then
        echo "nginx service failed to start. Exiting."
        exit 1
    fi
    sleep 5
done

echo "All services are up and running."