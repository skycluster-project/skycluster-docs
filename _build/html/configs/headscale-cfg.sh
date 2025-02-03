#!/bin/bash

# If env variables are not set, exit
if [ -z "$PUBLIC_IP" ]; then
  echo "PUBLIC_IP must be set."
  exit 1
fi

cat <<EOF > /var/lib/headscale/config.yaml
server_url: http://${PUBLIC_IP}:8080
listen_addr: 0.0.0.0:8080
metrics_listen_addr: 127.0.0.1:9090
grpc_listen_addr: 127.0.0.1:50443
grpc_allow_insecure: false
noise:
  private_key_path: /var/lib/headscale/noise_private.key
prefixes:
  v6: fd7a:115c:a1e0::/48
  v4: 100.64.0.0/10
  allocation: sequential
derp:
  server:
    enabled: false
disable_check_updates: true
ephemeral_node_inactivity_timeout: 30m
database:
  type: sqlite
  sqlite:
    path: /var/lib/headscale/db.sqlite
log:
  format: text
  level: info
acl_policy_path: "/var/lib/headscale/acl.json"
dns_config:
  override_local_dns: true
  nameservers:
    - 1.1.1.1
  magic_dns: true
  base_domain: example.com
unix_socket: /var/run/headscale/headscale.sock
unix_socket_permission: "0770"
logtail:
  enabled: false
randomize_client_port: false
EOF


cat <<EOF > /var/lib/headscale/acl.json
{
  "acls": [
    // Allow all connections.
    { "action": "accept", "src": ["*"], "dst": ["*:*"] },
  ],
  "groups": {
    "group:devops": ["client-skycluster"],
  },
  "autoApprovers": {
    "routes": {
      "10.0.0.0/8": ["group:devops", "client-skycluster"],
    }
  },
  "derpMap": {
    "Regions": {
      "1": null,
      "10": null,
      "11": null,
      "12": null,
      "13": null,
      "14": null,
      "15": null,
      "16": null,
      "17": null,
      "18": null,
      "19": null,
      "2": null,
      "20": null,
      "21": null,
      "22": null,
      "23": null,
      "24": null,
      "25": null,
      "26": null,
      "27": null,
      "3": null,
      "4": null,
      "5": null,
      "6": null,
      "7": null,
      "8": null,
      "9": null
    }
  }
}
EOF