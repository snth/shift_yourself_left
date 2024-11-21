#!/bin/bash
# run_integration_tests.sh

# Make the script exit on any error
set -e

# Clean up function
cleanup() {
    echo "Cleaning up..."
    docker compose down
    docker network rm recipe-network || true
}

# Setup cleanup trap
trap cleanup EXIT

# Cleanup any orphan containers that may be blocking ports
docker compose down --remove-orphans &>/dev/null || true

# Remove any existing network first
docker network rm recipe-network &>/dev/null || true

# Create a fresh network
echo "Creating a fresh network ?."
docker network create recipe-network

echo "Starting services and running integration tests..."
docker compose up integration-tests --build
INTEGRATION_TEST_EXIT=$?

if [ $INTEGRATION_TEST_EXIT -eq 0 ]; then
    echo "Integration tests passed successfully. Running pipeline..."
    # Don't bring down the network between runs
    docker compose down --remove-orphans
    docker compose up pipeline --build --abort-on-container-exit
    PIPELINE_EXIT=$?

    if [ $PIPELINE_EXIT -eq 0 ]; then
        echo "Pipeline completed successfully!"
        docker compose down -v  # Clean up everything including network
        exit 0
    else
        echo "Pipeline failed with exit code $PIPELINE_EXIT"
        docker compose down -v  # Clean up everything including network
        exit $PIPELINE_EXIT
    fi
else
    echo "Integration tests failed with exit code $INTEGRATION_TEST_EXIT. Pipeline will not run."
    docker compose down -v  # Clean up everything including network
    exit $INTEGRATION_TEST_EXIT
fi
