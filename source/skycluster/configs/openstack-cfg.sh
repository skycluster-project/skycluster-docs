#!/bin/bash

# Check if any of these variables are not set, if so exist
if [[ -z $AUTH_URL || -z $USERNAME || -z $PASSWORD || -z $TENANT_NAME || \
  -z $REGION || -z $USER_DOMAIN_NAME || -z $PROJECT_DOMAIN_NAME ]]; then
  echo "One or more required variables are not set."
  exit 1
fi

REGION_LOWER=$(echo $REGION | tr '[:upper:]' '[:lower:]')

cat <<EOF | kubectl apply -f -
apiVersion: openstack.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: provider-cfg-os-${REGION_LOWER}
  labels:
    skycluster.io/managed-by: skycluster
    skycluster.io/provider-region: ${REGION_LOWER}
spec:
  credentials:
    source: Secret
    secretRef:
      name: secret-os-${REGION_LOWER}
      namespace: skycluster
      key: configs
---
apiVersion: v1
kind: Secret
metadata:
  name: secret-os-${REGION_LOWER}
  namespace: skycluster
type: Opaque
stringData:
  configs: |
    {
      "auth_url": "$AUTH_URL",
      "region": "$REGION",
      "user_name": "$USERNAME",
      "password": "$PASSWORD",
      "tenant_name": "$TENANT_NAME",
      "project_domain_name": "$USER_DOMAIN_NAME",
      "user_domain_name": "$USER_DOMAIN_NAME",
      "insecure": "true"
    }
EOF