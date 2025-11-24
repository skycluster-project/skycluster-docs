Resource Configuration
-----------------------------
SkyCluster uses resource configuration files in YAML format to define the specifications for various resources such as providers, instances, and Kubernetes clusters. Below are examples of configuration files for different resource types.


``xprovider``
^^^^^^^^^^^^^^

.. code-block:: yaml

  # Unique identifier for the setup/application
  applicationId: aws-us-east
  
  vpcCidr: 10.40.0.0/16
  # Subnet CIDRs should be within the VPC CIDR range
  subnets:
    - type: public
      # Ensure the subnet CIDR range is within the VPC CIDR range
      # and does not overlap with other subnets and is 
      # appropriately sized for the expected number of resources
      # in this example, we reserve the half of the IPs
      cidr: 10.40.0.0/19	
      zone: us-east-1a
    - type: private
      cidr: 10.40.32.0/19	
      # Some services such as EKS require multiple availability zones
      # so we define a secondary zone here
      zone: us-east-1b
  gateway:
    # Flavor is defined as the number of vCPUs and memory
    flavor: 2vCPU-4GB
    volumeType: gp2
    volumeSize: 20
    
  providerRef:
    platform: aws
    region: us-east-1
    zones:
      # The provider is identified by the primary zone
      # Secondary zones are used for high availability or services
      # that require multiple availability zones such as EKS
      primary: us-east-1a
      secondary: us-east-1b

``xinstance``
^^^^^^^^^^^^^^

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