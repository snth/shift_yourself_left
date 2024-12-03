#!/bin/env bash

set -e

GARAGE_RPC_SECRET=$(openssl rand -hex 32)
GARAGE_ADMIN_TOKEN=$(openssl rand -base64 32)
GARAGE_METRICS_TOKEN=$(openssl rand -base64 32)
GARAGE_CONFIG_FILE="/etc/garage.toml"

cat >"${GARAGE_CONFIG_FILE}" <<EOF
metadata_dir = "/var/lib/garage/meta"
data_dir = "/var/lib/garage/data"
db_engine = "sqlite"

replication_factor = 1

rpc_bind_addr = "[::]:3901"
rpc_public_addr = "127.0.0.1:3901"
rpc_secret = "${GARAGE_RPC_SECRET}"

[s3_api]
s3_region = "garage"
api_bind_addr = "[::]:3900"
root_domain = ".s3.garage.localhost"

[s3_web]
bind_addr = "[::]:3902"
root_domain = ".web.garage.localhost"
index = "index.html"

[k2v_api]
api_bind_addr = "[::]:3904"

[admin]
api_bind_addr = "[::]:3903"
admin_token = "${GARAGE_ADMIN_TOKEN}"
metrics_token = "${GARAGE_METRICS_TOKEN}"
EOF

# Run the following in a backgrounded subshell
# so that we can exec into the garage process at the end
{
  while :; do
    echo "Waiting for garage server to start ..."
    /garage -c "${GARAGE_CONFIG_FILE}" status && break || sleep 1
  done

  # Create a garage node layout and apply it
  echo "Creating garage node ..."
  GARAGE_NODE=$(/garage -c "${GARAGE_CONFIG_FILE}" status | tail -n 1 | cut -d' ' -f1)
  echo "Assigning node ${GARAGE_NODE} to dc1 ..."
  /garage -c "${GARAGE_CONFIG_FILE}" layout assign -z dc1 -c 1G "${GARAGE_NODE}"
  /garage -c "${GARAGE_CONFIG_FILE}" layout show
  LAYOUT_VERSION=$(/garage -c "${GARAGE_CONFIG_FILE}" layout show | tail -n 1 | cut -d' ' -f5)
  /garage -c "${GARAGE_CONFIG_FILE}" layout apply --version $((LAYOUT_VERSION + 1))

  # Create  a garage key
  echo "Creating garage key ..."
  /garage key create app-key >app-key.txt
  GARAGE_KEY_ID=$(grep 'Key ID' app-key.txt | cut -d' ' -f3)
  GARAGE_KEY_SECRET=$(grep 'Secret key' app-key.txt | cut -d' ' -f3)

  # Give the key permission to create buckets
  /garage key allow --create-bucket app-key

  # Create a bucket
  /garage bucket create recipes
  /garage bucket list
  /garage bucket info recipes
  /garage bucket allow --read --write --owner recipes --key app-key

  # Inform the user how to use the key
  /garage key info app-key
  echo "Run the following command to use the garage key:"
  echo
  echo "cat >.awsrc <<EOF"
  cat >.awsrc <<EOF
export AWS_ACCESS_KEY_ID="${GARAGE_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${GARAGE_KEY_SECRET}"
export AWS_DEFAULT_REGION="garage"
export AWS_ENDPOINT_URL="http://localhost:3900"
EOF
  cat .awsrc
  echo EOF
  echo source .awsrc
  echo "# or"
  echo "docker cp garage:/.awsrc . && source .awsrc"
  echo
  echo Test the key with:
  echo
  echo aws s3 ls
  echo aws s3 cp Dockerfile s3://recipes/
  echo aws s3 ls s3://recipes/
} &

# Start garage server
echo "Starting garage server ..."
exec /garage -c "${GARAGE_CONFIG_FILE}" server
