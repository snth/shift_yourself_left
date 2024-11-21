#!/bin/bash
# start the web app + db for local testing

# Make the script exit on any error
set -e

# Remove any existing containers
docker compose down --remove-orphans &>/dev/null || true

# Remove any existing network first
docker network rm recipe-network &>/dev/null || true

# Create a fresh network
docker network create recipe-network

docker compose up --build ${1:-app}
