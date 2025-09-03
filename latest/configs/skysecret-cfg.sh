#!/bin/bash

# If env variables are not set, exit
if [ -z "$PUBLIC_KEY" ] || [ -z "$PRIVATE_KEY" ] || [ -z "$KUBECONFIG_B64" ]; then
  echo "PUBLIC_KEY, PRIVATE_KEY, and KUBECONFIG must be set."
  exit 1
fi

NAMESPACE="skycluster-system"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: ${NAMESPACE}
  name: public-private-key
  labels:
    skycluster.io/managed-by: skycluster
    skycluster.io/secret-type: default-keypair
type: Opaque
stringData:
  config: |
    {
      "publicKey": "$PUBLIC_KEY",
      "privateKey": "$PRIVATE_KEY"
    }
---
apiVersion: v1
kind: Secret
metadata:
  namespace: ${NAMESPACE}
  name: k8s-skycluster-management
  labels:
    skycluster.io/managed-by: skycluster
    skycluster.io/secret-type: k8s-connection-data
    skycluster.io/cluster-name: k8s-skycluster-management
type: Opaque
data:
  kubeconfig: "${KUBECONFIG_B64}"
EOF