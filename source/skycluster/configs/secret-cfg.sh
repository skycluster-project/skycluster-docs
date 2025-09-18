#!/bin/bash

# If env variables are not set, exit
if [ -z "$PRIVATE_KEY" ] || [ -z "$SECRET_NAME" ]; then
  echo "PRIVATE_KEY and SECRET_NAME must be set."
  exit 1
fi

NAMESPACE="skycluster-system"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: ${NAMESPACE}
  name: ${SECRET_NAME}
  labels:
    skycluster.io/managed-by: skycluster
    skycluster.io/secret-type: keypair-onpremise
type: Opaque
stringData:
  privateKey: "$PRIVATE_KEY"
EOF