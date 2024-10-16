#!/bin/bash

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
    nginx