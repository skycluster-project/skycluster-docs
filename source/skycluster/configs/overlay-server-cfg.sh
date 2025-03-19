#!/bin/bash

if [[ -z "$HOST" ]] || [[ -z "$TOKEN" ]] || [[ -z "$PORT" ]] || [[ -z $CA_CERTIFICATE ]]; then
  echo "HOST, TOKEN, PORT and CA_CERTIFICATE must be set."
  exit 1
fi

# Ensure $HOST does not start with http:// or https://
if [[ $HOST =~ ^https?:// ]]; then
  echo "Error: HOST should not start with http:// or https://"
  exit 1
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  namespace: skycluster
  name: overlay-server-cfg
  labels:
    skycluster.io/managed-by: skycluster
    skycluster.io/secret-type: overlay-server
type: Opaque
stringData:
  config: |
    {
      "host": "https://$HOST",
      "port": "$PORT",
      "token": "$TOKEN",
      "ca_cert": "$(cat $CA_CERTIFICATE | base64 -w0)"
    }
EOF