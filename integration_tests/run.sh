#!/bin/bash
# run_integration_tests.sh

# Make the script exit on any error
set -e

# Build and start the containers
docker-compose up -d

# Wait for the web service to be fully up (checking health endpoint)
echo "Waiting for services to be ready..."
bash -c 'SECONDS=0; while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' http://localhost:8000/health)" != "200" ]]; do if (( SECONDS > 30 )); then echo "Timed out"; exit 1; fi; sleep 5; done' || exit 1

# Run the integration tests
docker-compose run integration-tests

# Capture the exit code
TEST_EXIT_CODE=$?

# Clean up
docker-compose down

# Exit with the test exit code
exit $TEST_EXIT_CODE
