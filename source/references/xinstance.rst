XInstance
==========

.. code-block:: yaml

  # Unique identifier for the setup/application
  # Must be same as the one used in the provider instance (for AWS)
  applicationId: aws-us-east

  flavor: 2vCPU-4GB
  # Optional: set to true to use spot instances
  preferSpot: true

  # Images are defined by images.core.skycluster.io custom resources
  image: ubuntu-22.04

  # publicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3...
  # Optional: the default public key is used if not specified

  # If publicIp set to true, a public IP will be assigned to the instance
  publicIp: false

  # Optional: the user data should follow the cloud-init format
  userData: |
    #cloud-config
    write_files:
      - path: /tmp/hello.sh
        owner: root:root
        permissions: '0755'
        content: |
          #!/bin/sh
          echo "Hello, World!" > /tmp/hello.txt
    runcmd:
      - chmod +x /tmp/hello.sh
      - /tmp/hello.sh

  # Optional: security groups can be defined to allow specific ports
  securityGroups:
    tcpPorts:
      - fromPort: 22
        toPort: 22
        protocol: tcp
    udpPorts:
      - fromPort: 80
        toPort: 80
        protocol: udp

  # Optional
  rootVolumes:
    - size: "20"
      type: gp2 # pd-standard for GCP, gp2 for AWS

  providerRef:
    # Provider reference must match the one used in the provider instance
    platform: aws
    region: us-east-1
    zone: us-east-1a