Quick Start Examples
============================


This section provides quick start examples to help you get up and running with the SkyCluster. 

SkyCluster offers a unified plane across multiple providers to support running your applications in a multi-cloud environment. However, you can also use SkyCluster to deploy and manage applications within a single cloud provider or on-premises environment. The following examples demonstrate how to use SkyCluster in different deployment scenarios.

Single-Provider Example
-----------------------------------

Provision an environment where you can use as development and testing environment within a single cloud provider. When you are ready to deploy your application to production, you can easily migrate your workloads to a multi-cloud setup. 

  - Ensure you have followed the :doc:`installation </getting-started/installation>` section.
  - Ensure you have set up your cloud provider as described in the :doc:`provider profile </getting-started/providers-profile>` section.

Set up your provider
^^^^^^^^^^^^^^^^^^^^^^

Use yaml file below to prepare your cloud provider:

.. code-block:: yaml

  # Unique identifier for the setup/application
  applicationId: single-provider-example
  
  vpcCidr: 10.40.0.0/16
  # Subnet CIDRs should be within the VPC CIDR range
  subnets:
    - type: public
      # must be within the VPC CIDR range
      # and not have overlap with other subnets
      cidr: 10.40.0.0/19	
      zone: us-east-1a
    
      # Some services such as EKS require multiple availability zones
      # so we define a secondary zone here
    - type: private
      cidr: 10.40.32.0/19	
      zone: us-east-1b

  # Provider specifications
  providerRef:
    platform: aws
    region: us-east-1
    zones:
      # The provider is identified by the primary zone
      primary: us-east-1a
      # Secondary zones are used for high availability or services
      # that require multiple availability zones such as EKS
      secondary: us-east-1b

Create your environment by running the following command:

.. code-block:: bash

  skycluster create -f single-provider-example.yaml -n aws-us-east-1

  # Verify the environment is created, 
  # All fields must be populated
  skycluster xprovider list
  # NAME            PRIVATE_IP    PUBLIC_IP    CIDR_BLOCK
  # aws-us-east1                               10.40.0.0/16

You can use the dashboard to monitor and manage the resources hierarchy:

.. image:: ../_static/imgs/skycluster-dashboard-composition.jpg
   :alt: Provider Dashboard for Compositions
   :width: 90%
   :align: center
   :class: mb-3

Create a virtual machine
^^^^^^^^^^^^^^^^^^^^^^^^^

Now let's deploy a virtual machine:

.. code-block:: yaml

  applicationId: aws-us-east
  flavor: 2vCPU-4GB
  image: ubuntu-22.04

  # You don't need to specify public IP
  # since you can access the VM via overlay
  # publicIp: true

  rootVolumes:
    - size: 20Gi
      type: gp2
  
  providerRef:
    platform: aws
    region: us-east-1
    zone: us-east-1a


Multi-Provider Example
-----------------------------------