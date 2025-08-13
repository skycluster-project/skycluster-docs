#!/bin/bash

if [[ ! -f $AZURE_CONFIG_PATH ]]; then
  echo "Azure config file not found at $AZURE_CONFIG_PATH"
  exit 1
fi

NAMESPACE="skycluster-system"
cont_enc=$(cat $AZURE_CONFIG_PATH | base64 -w0)

cat <<EOF | kubectl apply -f -
apiVersion: azure.upbound.io/v1beta1
metadata:
  name: provider-cfg-azure
  labels:
    skycluster.io/managed-by: skycluster
kind: ProviderConfig
spec:
  credentials:
    source: Secret
    secretRef:
      namespace: ${NAMESPACE}
      name: secret-azure
      key: configs
---
apiVersion: v1
kind: Secret
metadata:
  name: secret-azure
  namespace: ${NAMESPACE}
  labels:
    skycluster.io/managed-by: skycluster
    skycluster.io/provider-platform: azure
    skycluster.io/secret-role: credentials 
type: Opaque
data:
  configs: $cont_enc
EOF