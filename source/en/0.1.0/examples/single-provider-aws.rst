Single Cluster (AWS)
####################

.. toctree::
  :hidden:

Make sure you have prerequisites installed and configured. 

Prepare Provider
=================

Create the a provider instance for AWS:

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XProviderInstance
    metadata:
      name: aws-provider-us-east
    spec:
      applicationId: my-app
      # Unique identifier for the setup/application
      
      vpcCidr: 10.15.0.0/16
      # vpcCidr is used region-wide for all services and resources in this VPC
      
      subnets:
      # Subnet CIDRs should be within the VPC CIDR range
        - type: public
          cidr: 10.15.0.0/19
          # Ensure the subnet CIDR range is within the VPC CIDR range
          # and does not overlap with other subnets and is 
          # appropriately sized for the expected number of resources
          zone: us-east-1a
        - type: private
          cidr: 10.15.32.0/19
          zone: us-east-1b
          # Some services such as EKS require multiple availability zones
          # so we define a secondary zone here
      
      gateway:
        flavor: 2vCPU-4GB
        # Flavor is defined as the number of vCPUs and memory
        volumeType: gp2
        volumeSize: 20
      
      providerRef:
        platform: aws
        region: us-east-1
        zones:
          primary: us-east-1a
          # The provider is identified by the primary zone
          # Secondary zones are used for high availability or services
          # that require multiple availability zones such as EKS
          secondary: us-east-1b

The above example creates multiple resources in AWS, including a VPC, subnets, security groups, and IAM roles. The AWS in region ``us-east-1`` is now ready to be used for deploying other resources such as virtual machines, Kubernetes clusters, databases, or other services.

Virtual Instance
=================

Now let's create a virtual instance using the provider instance we just created:

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XInstance
    metadata:
      name: example-instance-us-east
    spec: 
      applicationId: my-app
      # Unique identifier for the setup/application
      # Must be same as the one used in the provider instance
      
      flavor: 2vCPU-4GB
      
      image: ubuntu-22.04
      # Images are defined by images.skycluster.io custom resources
      # publicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3...
      # Optional: the default public key is used if not specified
      
      publicIp: false
      
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
      # Optional: the user data should follow the cloud-init format
      
      # securityGroups:
      #   tcpPorts:
      #     - fromPort: 22
      #       toPort: 22
      #       protocol: tcp
      #   udpPorts:
      #     - fromPort: 80
      #       toPort: 80
      #       protocol: udp
      # Optional: security groups can be defined to allow specific ports

      # rootVolumes:
      #   - size: 20Gi
      #     type: gp2
      # Optional
      
      providerRef:
        # Provider reference must match the one used in the provider instance
        platform: aws
        region: us-east-1
        zone: us-east-1a


Kubernetes Cluster (AWS EKS Cluster)
=====================================

Now let's create a Kubernetes cluster using the provider instance we just created:

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XK8S
    metadata:
      name: example-cluster-us-east
    spec:
      applicationId: my-app
      # Unique identifier for the setup/application
      # Must be same as the one used in the provider instance
      
      serviceCidr: 172.20.0.0/16
      
      nodeTypes:
        - 2vCPU-4GB
      
      principal:
        # Optional: the principal is used to authenticate the role
        # to view and manage the cluster through the AWS CLI or UI
        type: servicePrincipal # user | role | serviceAccount | servicePrincipal | managedIdentity
        id: "arn:aws:iam::885707601199:root" # ARN (AWS) | member (GCP) | principalId (Azure)
      
      providerRef:
        # Provider reference must match the one used in the provider instance
        platform: aws
        region: us-east-1
        zones:
          # The provider is identified by the primary zone
          # Secondary zones are used for high availability or services
          # that require multiple availability zones such as EKS
          primary: us-east-1a
          secondary: us-east-1b