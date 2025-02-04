#!/bin/bash

set -e

# If env variables are not set, exit
if [ -z "$PUBLIC_IP" ]; then
  echo "PUBLIC_IP must be set."
  exit 1
fi

CONFIG_DIR="/var/lib/headscale/"

sudo tee /etc/headscale/config.yaml > /dev/null <<EOF
server_url: https://${PUBLIC_IP}:8080
listen_addr: 0.0.0.0:8080
metrics_listen_addr: 127.0.0.1:9090
grpc_listen_addr: 127.0.0.1:50443
grpc_allow_insecure: false
noise:
  private_key_path: ${CONFIG_DIR}/noise_private.key
prefixes:
  v6: fd7a:115c:a1e0::/48
  v4: 100.64.0.0/10
  allocation: sequential
derp:
  urls:
    - https://controlplane.tailscale.com/derpmap/default
  server:
    enabled: false
    region_id: 999
    region_code: "headscale"
    region_name: "Headscale Embedded DERP"
    stun_listen_addr: "0.0.0.0:3478"
    private_key_path: ${CONFIG_DIR}/derp_server_private.key
    automatically_add_embedded_derp_region: true
    ipv4: 1.2.3.4
    ipv6: 2001:db8::1
disable_check_updates: true
ephemeral_node_inactivity_timeout: 30m
database:
  type: sqlite
  sqlite:
    path: ${CONFIG_DIR}/db.sqlite
log:
  format: text
  level: info
tls_cert_path: ${CONFIG_DIR}/app_certificate.crt
tls_key_path: ${CONFIG_DIR}/app_private_key.pem
policy:
  mode: file
  path: "${CONFIG_DIR}/acl.json"
dns:
  nameservers:
    global:
      - 1.1.1.1
      - 1.0.0.1
      - 2606:4700:4700::1111
      - 2606:4700:4700::1001
  magic_dns: true
  base_domain: example.com
unix_socket: /var/run/headscale/headscale.sock
unix_socket_permission: "0770"
logtail:
  enabled: false
randomize_client_port: false
EOF

sudo tee ${CONFIG_DIR}/acl.json > /dev/null <<EOF
{
  "acls": [
    // Allow all connections.
    { "action": "accept", "src": ["*"], "dst": ["*:*"] },
  ],
  "groups": {
    "group:devops": ["client-skycluster"],
  },
  "autoApprovers": {
    "routes": {
      "10.0.0.0/8": ["group:devops", "client-skycluster"],
    }
  },
  "derpMap": {
    "Regions": {
      "1": null,
      "10": null,
      "11": null,
      "12": null,
      "13": null,
      "14": null,
      "15": null,
      "16": null,
      "17": null,
      "18": null,
      "19": null,
      "2": null,
      "20": null,
      "21": null,
      "22": null,
      "23": null,
      "24": null,
      "25": null,
      "26": null,
      "27": null,
      "3": null,
      "4": null,
      "5": null,
      "6": null,
      "7": null,
      "8": null,
      "9": null
    }
  }
}
EOF

# Function to handle errors
error_exit() {
    echo "Error: $1" >&2
    exit 1
}


# Generate application private key
openssl genpkey -algorithm RSA -out ${CONFIG_DIR}/app_private_key.pem
# Generate application public key
openssl rsa -pubout -in ${CONFIG_DIR}/app_private_key.pem -out ${CONFIG_DIR}/app_public_key.pem
# Generate application CSR
openssl req -new -key ${CONFIG_DIR}/app_private_key.pem -out ${CONFIG_DIR}/app_csr.csr \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=Unit/CN=app.example.com"

# Generate CA private key
openssl genpkey -algorithm RSA -out ${CONFIG_DIR}/ca_private_key.pem

# Generate CA certificate
openssl req -x509 -new -key ${CONFIG_DIR}/ca_private_key.pem -out ${CONFIG_DIR}/ca_certificate.crt \
  -days 365 -subj "/C=US/ST=State/L=City/O=CAOrganization/OU=CAUnit/CN=ca.example.com"

# Sign application certificate with CA
openssl x509 -req -in ${CONFIG_DIR}/app_csr.csr \
  -CA ${CONFIG_DIR}/ca_certificate.crt \
  -CAkey ${CONFIG_DIR}/ca_private_key.pem \
  -CAcreateserial -out ${CONFIG_DIR}/app_certificate.crt \
  -days 365

# Copy to the current location
sudo cp ${CONFIG_DIR}/ca_certificate.crt .

# Enable and start headscale service
echo "Enabling and starting headscale service..."
sudo systemctl enable --now headscale || error_exit "Failed to enable/start headscale service."

# Check headscale service status
sudo systemctl status headscale || error_exit "headscale service is not running properly."

# Create headscale user
echo "Creating user 'client-skycluster'..."
sudo headscale users create client-skycluster -o json || error_exit "Failed to create user 'client-skycluster'."

# Create pre-auth key
echo "Creating pre-authentication key for 'client-skycluster'..."
sudo headscale pre create --expiration 365d --reusable --ephemeral -u client-skycluster || error_exit "Failed to create pre-auth key for 'client-skycluster'."

# Retrieve pre-auth key
KEY=$(sudo headscale pre list --user client-skycluster -o yaml)
if [ -n "$KEY" ]; then
  echo
  echo "Pre-auth key: $KEY"
  echo
else
  error_exit "Error: Failed to retrieve pre-auth key."
fi