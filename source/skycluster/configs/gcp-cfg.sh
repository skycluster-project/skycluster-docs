#!/bin/bash

if [[ -z "$GCP_SVC_ACC_PATH" ]] || [[ -z "$PROJECT_ID" ]] || [[ -z "$NAMESPACE" ]]; then
  echo "GCP_SVC_ACC_PATH and PROJECT_ID and NAMESPACE must be set."
  exit 1
fi

# if file does not exist, exit
if [[ ! -f "$GCP_SVC_ACC_PATH" ]]; then
  echo "GCP_SVC_ACC_PATH File does not exist. Ensure the file exists and use the absolute path."
  exit 1
fi

BASE64_ENCODED_GCP_SVC_ACC=$(cat "$GCP_SVC_ACC_PATH" | base64 -w0)

if [[ -z "$BASE64_ENCODED_GCP_SVC_ACC" ]]; then
  echo "Failed to encode GCP service account file."
  exit 1
fi

# Apply the provider configuration
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: secret-gcp
  namespace: ${NAMESPACE}
type: Opaque
data:
  configs: ${BASE64_ENCODED_GCP_SVC_ACC}
---
apiVersion: gcp.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: provider-cfg-gcp
  labels:
    skycluster.io/managed-by: skycluster
spec:
  projectID: ${PROJECT_ID}
  credentials:
    source: Secret
    secretRef:
      namespace: ${NAMESPACE}
      name: secret-gcp
      key: configs
EOF