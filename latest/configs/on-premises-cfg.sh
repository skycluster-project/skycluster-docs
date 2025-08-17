#!/bin/bash

# Check if any of these variables are not set, if so exist
if [[ -z $GW_URL || -z $USERNAME || -z $PRIVATE_KEY_PATH || -z $REGION ]]; then
  echo "One or more required variables are not set."
  exit 1
fi

NAMESPACE="skycluster-system"
REGION_LOWER=$(echo $REGION | tr '[:upper:]' '[:lower:]')
PRIVATE_KEY=$(cat $PRIVATE_KEY_PATH | base64 -w0)
cat <<EOF | kubectl apply -f -
---
apiVersion: v1
kind: Secret
metadata:
  name: secret-onpremises-${REGION_LOWER}
  namespace: ${NAMESPACE}
type: Opaque
stringData:
  configs: |
    {
      "gw_url": "$GW_URL",
      "region": "$REGION",
      "user_name": "$USERNAME",
      "private_key": "$PRIVATE_KEY",
    }
EOF