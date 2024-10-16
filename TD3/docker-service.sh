#!/bin/bash

# Build the custom nginx image
docker build -t nginx-custom /home/vagrant/config

# Create the registry service
docker service create --name registry --publish published=5000,target=5000 registry:2

# Push the custom nginx image to the local registry
docker tag nginx-custom localhost:5000/nginx-custom
docker push localhost:5000/nginx-custom

# Create the overlay network
docker network create --driver=overlay traefik-public

# Create the Traefik service
docker service create \
        --name traefik \
        --constraint=node.role==manager \
        -p 80:80 \
        -p 8080:8080 \
        -p 443:443 \
        --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
        --network traefik-public \
        --mode global \
        traefik:v2.10 \
        --api.insecure=true \
        --providers.docker \
        --providers.docker.swarmMode \
        --providers.docker.exposedbydefault=false \
        --entrypoints.web.address=:80

docker service create \
    --name nginx-service \
    --replicas=3 \
    --network traefik-public \
    --label "traefik.enable=true" \
    --label "traefik.http.routers.nginx.rule=Host(\`example.com\`)" \
    --label "traefik.http.services.nginx.loadbalancer.server.port=80" \
    --restart-condition on-failure \
    #--limit-cpu 4 \
    #--limit-memory 4GB \
    #--constraint 'node.role==worker' \
    192.168.56.101:5000/nginx-custom