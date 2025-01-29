#!/bin/bash

if [[ -z "$GCP_SVC_ACC_PATH" ]] || [[ -z "$PROJECT_ID" ]] ; then
  echo "GCP_SVC_ACC_PATH and PROJECT_ID must be set."
  exit 1
fi

# if file does not exist, exit
if [[ ! -f "$GCP_SVC_ACC_PATH" ]]; then
  echo "GCP_SVC_ACC_PATH File does not exist. Ensure the file exists and use the absolute path."
  exit 1
fi

kubectl create secret generic secret-gcp -n skycluster --from-file=configs=${GCP_SVC_ACC_PATH}

# Apply the provider configuration
cat <<EOF | kubectl apply -f -
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
      namespace: skycluster
      name: secret-gcp
      key: configs
EOF