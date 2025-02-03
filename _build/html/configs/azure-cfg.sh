#!/bin/bash

if [[ ! -f $AZURE_CONFIG_PATH ]]; then
  echo "Azure config file not found at $AZURE_CONFIG_PATH"
  exit 1
fi

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
      namespace: skycluster
      name: secret-azure
      key: configs
---
apiVersion: v1
kind: Secret
metadata:
  name: secret-azure
  namespace: skycluster
type: Opaque
data:
  configs: $cont_enc
EOF