#!/bin/bash
# start the web app + db for local testing

# Make the script exit on any error
set -e

# Remove any existing network first
docker network rm recipe-network || true

# Create a fresh network
docker network create recipe-network

docker compose up integration-tests -d --build
