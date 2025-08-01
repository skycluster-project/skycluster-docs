#!/bin/bash

set -euo pipefail

CA_CERT=$(kubectl get secret skycluster-self-ca \
  -n skycluster-system -o jsonpath='{.data.ca\.crt}')

if [[ -z "$CA_CERT" ]]; then
  echo "Error: CA certificate not found in skycluster-self-ca secret" >&2
  exit 1
fi

echo "$CA_CERT" | base64 -d | sudo tee /usr/local/share/ca-certificates/skycluster.crt > /dev/null
sudo update-ca-certificates

