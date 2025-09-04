Setup Provider Setup
#######################

.. toctree::
  :hidden:

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

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XProvider
    metadata:
      name: aws-provider-us-east
    spec:

      # Unique identifier for the setup/application
      applicationId: aws-us-east
    
      # vpcCidr is used region-wide for all services and resources in this VPC
      vpcCidr: 10.15.0.0/16
    
      # Subnet CIDRs should be within the VPC CIDR range
      subnets:
        - type: public
          # Ensure the subnet CIDR range is within the VPC CIDR range
          # and does not overlap with other subnets and is 
          # appropriately sized for the expected number of resources
          cidr: 10.15.0.0/19
          zone: us-east-1a
    
        - type: private
          cidr: 10.15.32.0/19
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

.. note::

  You can determine the appropriate CIDR size for your provider by using the ``skycluster`` 
  CLI commands and provide the VPC CIDR. For example, for the VPC CIDR of ``10.15.0.0/16``:

  .. code-block:: sh

    skycluster subnet 10.15.0.0/16 -p aws
    # NAME                     CIDR
    # └── VPC                  10.15.0.0/16
    #     ├── Subnet Range     10.15.0.0/17
    #     └── Pod Range        10.15.128.0/17
    #         ├── Primary      10.15.128.0/18
    #         └── Secondary    10.15.192.0/18
    # └── Service Range        172.15.0.0/16


The above example creates multiple resources in AWS, including a VPC, subnets, security groups, and IAM roles. 
Once the ``XProvider`` resource becomes ready, the region ``us-east-1`` is ready for deploying other resources such as virtual machines, Kubernetes clusters, databases, or other services.

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


Virtual Instance
=================

Now let's create a virtual instance using the provider instance we just created:

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XInstance
    metadata:
      name: example-instance-us-east
    spec: 
      # Unique identifier for the setup/application
      # Must be same as the one used in the provider instance
      applicationId: aws-us-east
      
      flavor: 2vCPU-4GB
      
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
      # securityGroups:
      #   tcpPorts:
      #     - fromPort: 22
      #       toPort: 22
      #       protocol: tcp
      #   udpPorts:
      #     - fromPort: 80
      #       toPort: 80
      #       protocol: udp

      # Optional
      # rootVolumes:
      #   - size: 20Gi
      #     type: gp2
      
      providerRef:
        # Provider reference must match the one used in the provider instance
        platform: aws
        region: us-east-1
        zone: us-east-1a


.. note::

  Check the status of the ``XInstance`` resource by running the following command or through :doc:`/getting-started/skycluster-dashboard`.

  .. code-block:: sh

    kubectl get xinstances.skycluster.io
    # NAME                          SYNC     STATUS
    # example-instance-us-east      Ready    Ready

  You can also use the SkyCluster cli commadnd:

  .. code-block:: sh

    skycluster xinstance list
    # NAME                            PUBLIC_IP        PRIVATE_IP
    # example-kube-os-scinet-nd4qq                     10.16.128.12
    # example-kube-os-scinet-w4mtz    142.1.174.183    10.16.128.16

If you enable a public IP for your ``XInstance``, you can access it directly from anywhere
using the instance’s ``External IP``.  
Otherwise, the instance is accessible only via its private IP from the machine running the SkyCluster system.

You need to use the key described in the SkyCluster Secret configuration section of :doc:`/getting-started/installation`.

.. code-block:: sh

  ssh -i id_rsa ubuntu@<instance-ip>



Managed Kubernetes Cluster 
==============================================

Now let's create a managed Kubernetes cluster using the provider instance we just created. Since we 
are using ``AWS`` as the provider in this example, this will be an EKS cluster.

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XKube
    metadata:
      name: example-aws-kube
    spec:
      # Unique identifier for the setup/application
      applicationId: aws-us-east

      # Service CIDR must not overlap with the VPC CIDR
      serviceCidr: 172.20.0.0/16
      
      podCidr: 
        # AWS EKS requires two zones, each with a non-overlapping subnet
        primary: 10.15.0.0/18     # subnet for primary zone
        secondary: 10.15.64.0/18  # subnet for secondary zone
      
      nodeGroups:
        # At least one node group must allow public access (gateway nodes)
        - instanceTypes: "2vCPU-4GB"
          publicAccess: true       # required for at least one node group
          autoScaling: 
            enabled: false
            minCount: 1
            maxCount: 1

        # Optional additional node group
        - instanceTypes: "2vCPU-4GB"
          publicAccess: false
          autoScaling: 
            enabled: false
            minCount: 1
            maxCount: 1

      principal:
        type: servicePrincipal # user | role | serviceAccount | servicePrincipal | managedIdentity
        id: "arn:aws:iam::885707601199:root" # ARN (AWS) | member (GCP) | principalId (Azure)

      providerRef:
        platform: aws
        region: us-east-1
        zones:
          # The provider is identified by the primary zone
          # Secondary zones are used for high availability or services
          # that require multiple availability zones such as EKS
          primary: us-east-1a
          secondary: us-east-1b


.. note::

  You can determine the appropriate CIDR size for your provider by using the ``skycluster`` 
  CLI commands and provide the VPC CIDR.

  .. container:: toggle 

    .. container:: header

      **Example:**

    .. code-block:: sh

      skycluster subnet 10.15.0.0/16 -p aws
      # NAME                     CIDR
      # └── VPC                  10.15.0.0/16
      #     ├── Subnet Range     10.15.0.0/17
      #     └── Pod Range        10.15.128.0/17
      #         ├── Primary      10.15.128.0/18
      #         └── Secondary    10.15.192.0/18
      # └── Service Range        172.15.0.0/16

.. note::

  Check the status of the ``XKube`` instance by running the following command or through :doc:`/getting-started/skycluster-dashboard`.

  .. code-block:: sh

    kubectl get xkubes.skycluster.io
    # NAME                          SYNC     STATUS
    # example-instance-us-east      Ready    Ready

  You can also use the SkyCluster cli commadnd:

  .. code-block:: sh

    skycluster xkubes list 


Once you initialize and set up a provider, you can create additional ``XProvider`` resources to integrate other cloud providers such as GCP and Azure. When you have more than two providers configured, you are ready to follow the multi-provider examples. 

For GCP GKE service:

.. code-block:: sh

  skycluster xkubes list 
  # note gcp cluster with external name

  # use gcloud to setup kubeconfig
  gcloud container clusters get-credentials <external-name> --location <location>

  # please refer to 
  # https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl