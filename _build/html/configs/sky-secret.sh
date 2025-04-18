#!/bin/bash

# If env variables are not set, exit
if [ -z "$PUBLIC_KEY" ] || [ -z "$PRIVATE_KEY" ]; then
  echo "PUBLIC_KEY and PRIVATE_KEY must be set."
  exit 1
fi

# Echo the content and pipe it to base64 for encoding
creds_enc=$(echo "$creds_content" | base64 -w0)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: skycluster
  name: public-private-key
type: Opaque
stringData:
  config: |
    {
      "public_key": $PUBLIC_KEY,
      "privateKey": $PRIVATE_KEY,
    }
EOF