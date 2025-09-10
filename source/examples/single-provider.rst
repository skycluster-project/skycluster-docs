Setup Provider Setup
#######################

.. toctree::
  :hidden:

  xinstance
  xkube

Make sure you have followed steps in :doc:`/getting-started/index` and ensure all  
prerequisites installed and configured, including:

- :doc:`/getting-started/providers-auth`
- :doc:`/getting-started/providers-profile`
- :doc:`/getting-started/skycluster-configs`


Initializing Provider
======================

By creating a ``XProvider`` resource, SkyCluster creates a virtual private network and a virtual machine 
with a static IP address that serves as the gateway for all services and resources inside your VPC. 
It configures routing and sets up overlay networks to provide access to VPC resources. Charges apply 
as services are provisioned, and when the Provider is deleted, SkyCluster automatically cleans up all associated services.

Before creating a ``XProvider`` resource, ensure you have a ``ProviderProfile`` instance created and ready for this provider:

.. code-block:: sh

  kubectl get providerprofile
  # NAME                  PLATFORM    REGION      READY
  # aws-us-east-1         aws         us-east-1   True

Then create a ``XProvider`` resource:

.. tabs::

  .. tab:: AWS

      .. code-block:: yaml

        apiVersion: skycluster.io/v1alpha1
        kind: XProvider
        metadata:
          name: aws-provider-us-east
        spec:

          # Unique identifier for the setup/application
          applicationId: aws-us-east
        
          # vpcCidr is used region-wide for all services and resources in this VPC
          vpcCidr: 10.16.0.0/16
        
          # Subnet CIDRs should be within the VPC CIDR range
          subnets:
            - type: public # public | private
              # Public subnets are used for resources that need direct internet access
              # The subnet CIDR range must be within the VPC CIDR range
              # and does not overlap with other subnets and is
              # appropriately sized for the expected number of resources
              cidr: 10.16.0.0/19
              zone: us-east-1a
        
            - type: private
              cidr: 10.16.32.0/19
              # Some services such as EKS require multiple availability zones
              # so we define a secondary zone here
              zone: us-east-1b
        
          gateway:
            # Flavor is defined as the number of vCPUs and memory
            flavor: 2vCPU-4GB
            volumeType: gp2
            volumeSize: 20

          providerRef:
            # ProviderRef is a reference to the ProviderProfile instance
            # Where it identifies a single provider by its platform and region
            platform: aws
            region: us-east-1
            zones:
              # The provider is identified by the primary zone
              # Secondary zones are used for high availability or services
              # that require multiple availability zones such as EKS
              primary: us-east-1a
              secondary: us-east-1b

  .. tab:: GCP

      .. code-block:: yaml
  
        apiVersion: skycluster.io/v1alpha1
        kind: XProvider
        metadata:
          name: gcp-provider-us-east1
        spec:

          # Unique identifier for the setup/application
          applicationId: gcp-us-east1
          
          # Subnet CIDRs should be within the VPC CIDR range
          subnets:
            - cidr: 10.17.224.0/19
              # The subnet CIDR range must be within the VPC CIDR range
              # and does not overlap with other subnets and is
              # appropriately sized for the expected number of resources
              zone: us-east1-b

          gateway:
            # Flavor is defined as the number of vCPUs and memory
            flavor: 2vCPU-4GB
            # volumeType: pd-standard
            # volumeSize: 20
            
          providerRef:
            platform: gcp
            region: us-east1
            zones:
              # The provider is identified by the primary zone
              primary: us-east1-b

  .. tab:: OpenStack

      .. code-block:: yaml
  
        apiVersion: skycluster.io/v1alpha1
        kind: XProvider
        metadata:
          name: os-provider-scinet

          annotations:
            skycluster.io/external-resources: '[{"apiVersion":"identity.openstack.crossplane.io/v1alpha1","kind":"ProjectV3","id":"1e1c712348544xyzw9055647aaa8f30b"}]'
            # You can use the existing external resources by specifying the 
            # resource api version, kind and ID in the annotation as shown above, 
            # otherwise SkyCluster will create a new project for you.

        spec:

          # Unique identifier for the setup/application
          applicationId: os-scinet
          
          # vpcCidr is used region-wide for all services and resources in this VPC
          vpcCidr: 10.15.0.0/17
          # Subnet CIDRs should be within the VPC CIDR range

          externalNetwork:
            # extNetwork is the external network that provides internet access
            # to the resources in the VPC. It must be pre-created in OpenStack.
            # You can specify either the network name or ID.
            networkName: ext-net
            networkId: 0a23c4ae-abcd-abcd-zyzw-5a7dc614cc4e
            subnetName: ext-subnet
            subnetId: ae9a8eac-abcd-1234-1234-71acf18dcfbb

          subnets:
            - cidr: 10.15.0.0/18
              # The subnet CIDR range must be within the VPC CIDR range
              # and does not overlap with other subnets and is
              # appropriately sized for the expected number of resources
              zone: default
              default: True
              # There must be one default subnet for the provider
              # and it is used for the gateway setup

          gateway:
            # Flavor is defined as the number of vCPUs and memory
            flavor: 2vCPU-4GB
            # volumeType: gp2
            # volumeSize: 20

          providerRef:
            platform: openstack
            region: SCINET
            zones:
              # The provider is identified by the primary zone
              primary: default

.. note::

  You can determine the appropriate CIDR size for your provider by using the ``skycluster`` 
  CLI commands and provide the VPC CIDR. For example, for the VPC CIDR of ``10.16.0.0/16``:

  .. code-block:: sh

    skycluster subnet 10.16.0.0/16 -p aws
    #     NAME                             CIDR
    # └── VPC                          10.16.0.0/16
    #     ├── Subnet Range             10.16.0.0/17
    #     └── XKube Pod Range (EKS)    10.16.128.0/17
    #         ├── Primary              10.16.128.0/18
    #         └── Secondary            10.16.192.0/18
    # └── XKube Service Range (EKS)    172.16.0.0/16

    skycluster subnet 10.17.0.0/16 -p gcp
    #     NAME                              CIDR
    # └── VPC                           10.17.0.0/16
    #     ├── Subnet Range              10.17.0.0/17
    #     └── XKube Node Range (GKE)    10.17.128.0/17
    # └── Pod/Service Range             172.17.0.0/16


The above example creates multiple resources in your project, including a VPC, subnets, security groups, and IAM roles. Once the ``XProvider`` resource becomes ready, the region ``us-east-1`` is ready for deploying other resources such as virtual machines, Kubernetes clusters, databases, or other services.

.. note::

  Check the status of the ``XProvider`` instance by running the following command or through :doc:`/getting-started/skycluster-dashboard`.

  .. code-block:: sh

    kubectl get xproviderd.skycluster.io
    # NAME                      SYNC     STATUS
    # aws-provider-us-east      Ready    Ready

  You can also use the SkyCluster cli commadnd:

  .. code-block:: sh

    skycluster xprovider list
    # NAME                  PRIVATE_IP      PUBLIC_IP        CIDR_BLOCK
    # os-provider-scinet    10.16.128.11    142.1.174.185    10.16.0.0/16


