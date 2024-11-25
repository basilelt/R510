#!/bin/bash

# Deploy services using docker-compose.yml
echo "Deploying stack with custom docker-compose.yml..."
docker stack deploy -c /vagrant/docker-compose.yml my_stack

# Wait for the stack services to be ready
echo "Waiting for stack services to be ready..."
for i in {1..30}; do
    if docker stack ps my_stack --no-trunc | grep -q "Running"; then
        echo "Stack services are running."
        break
    fi
    if [ $i -eq 30 ]; then
        echo "Stack services failed to start. Exiting."
        exit 1
    fi
    sleep 5
done

echo "All services are up and running."