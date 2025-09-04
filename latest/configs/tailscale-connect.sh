#!/bin/bash

set -euo pipefail

HEADSCALE_DATA=$(kubectl get secret headscale-connection-secret \
  -n skycluster-system -o jsonpath='{.data}')

if [[ -z "$HEADSCALE_DATA" ]]; then
  echo "Error: Headscale data not found in headscale-connection-secret secret" >&2
  exit 1
fi

# KEY
HEADSCALE_KEY=$(echo "$HEADSCALE_DATA" | jq -r '."preauth.json"' | base64 -d | jq -r '.key')
if [[ -z "$HEADSCALE_KEY" ]]; then
  echo "Error: Headscale key not found in headscale-connection-secret secret" >&2
  exit 1
fi

# Enforce update-ca-certificates
sudo update-ca-certificates --fresh
# Restart Tailscale service to apply changes
sudo systemctl restart tailscaled

# TAILSCALE IP
SERVER="https://$(curl -s ifconfig.io):8080"
sudo tailscale up --login-server $SERVER --auth-key $HEADSCALE_KEY --accept-routes