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
      name: ex1
    spec:
      # Unique identifier for the setup/application
      applicationId: ex1-app
      # vpcCidr is used region-wide for all services and resources in this VPC
      vpcCidr: 10.10.0.0/16
      # Subnet CIDRs should be within the VPC CIDR range
      subnets:
        - type: public
          cidr: 10.10.0.0/16
          zone: us-west-2a
        - type: private
          cidr: 10.10.1.0/24
          zone: us-west-2b
      gateway:
        flavor: 2vCPU-4GB
        volumeType: gp2
        volumeSize: 8
      providerRef:
        platform: aws
        region: us-east-1
        zones:
          # The provider is identified by the primary zone
          # Secondary zones are used for high availability or services
          # that require multiple availability zones such as EKS
          primary: us-east-1a
          secondary: us-east-1b

The above example creates multiple resources in AWS, including a VPC, subnets, security groups, and IAM roles. The AWS in region ``us-east-1`` is now ready to be used for deploying other resources such as virtual machines, Kubernetes clusters, databases, or other services.

AWS EKS Cluster
=================

Now let's create a Kubernetes cluster using the provider instance we just created:

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XK8S
    metadata:
      name: ex1
    spec:
      # Unique identifier for the setup/application
      applicationId: ex1-app
      serviceCidr: 10.0.0.0/24
      nodeTypes:
        - "t3.medium"
      providerRef:
        platform: aws
        region: us-east-1
        zones:
          # The provider is identified by the primary zone
          # Secondary zones are used for high availability or services
          # that require multiple availability zones such as EKS
          primary: us-east-1a
          secondary: us-east-1b