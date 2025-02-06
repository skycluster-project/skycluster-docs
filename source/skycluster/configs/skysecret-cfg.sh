#!/bin/bash

# If env variables are not set, exit
if [ -z "$PUBLIC_KEY" ] || [ -z "$PRIVATE_KEY" ]; then
  echo "PUBLIC_KEY and PRIVATE_KEY must be set."
  exit 1
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: skycluster
  name: public-private-key
  labels:
    skycluster.io/managed-by: skycluster
    skycluster.io/secret-type: keypair
type: Opaque
stringData:
  config: |
    {
      "publicKey": "$PUBLIC_KEY",
      "privateKey": "$PRIVATE_KEY"
    }
EOF