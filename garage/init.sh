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

# Start garage server
echo "Starting garage server ..."
/garage -c "${GARAGE_CONFIG_FILE}" server &
GARAGE_SERVER_PID=$!
while :; do
  echo "Waiting for garage server to start ..."
  /garage -c "${GARAGE_CONFIG_FILE}" status && break || sleep 1
done

# Create a garage node
echo "Creating garage node ..."
# /garage -c "${GARAGE_CONFIG_FILE}" status | tail -n 1 | cut -d' ' -f1 | tee garage_node
GARAGE_NODE=$(/garage -c "${GARAGE_CONFIG_FILE}" status | tail -n 1 | cut -d' ' -f1)
echo "Assigning node ${GARAGE_NODE} to dc1 ..."
/garage -c "${GARAGE_CONFIG_FILE}" layout assign -z dc1 -c 1G "${GARAGE_NODE}"
/garage -c "${GARAGE_CONFIG_FILE}" layout show
LAYOUT_VERSION=$(/garage -c "${GARAGE_CONFIG_FILE}" layout show | tail -n 1 | cut -d' ' -f5)
/garage -c "${GARAGE_CONFIG_FILE}" layout apply --version $((LAYOUT_VERSION + 1))

# Create  a garage key
echo "Creating garage key ..."
/garage key create app-key | tee app-key.txt
GARAGE_KEY_ID=$(grep 'Key ID' app-key.txt | cut -d' ' -f3)
GARAGE_KEY_SECRET=$(grep 'Secret key' app-key.txt | cut -d' ' -f3)

# Finish
wait "${GARAGE_SERVER_PID}"
