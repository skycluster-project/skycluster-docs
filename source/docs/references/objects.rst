.. toctree::
  :hidden:


Primary Objects
###############




SkyProvider Object
==================

``SkyProvider`` is an object that represents a cloud provider.
By creating a SkyProvider object, a gateway node is created 
and acts as a reouter to connect this provider to the overlay network.
During this setup, the security groups, keypairs and other required 
resources are created. 

The ``gateway`` object specifies the gateway node configuration. 
It is recommended to use a flavor that provides **at least 4 vCPUs** to provide 
enough computing power required for encrypting traffic when
there is a high volume of traffic involved.

.. container:: toggle open

  .. code-block:: yaml
    :linenos:
    :emphasize-lines: 19,28,34,44,61-63

    apiVersion: xrds.skycluster.io/v1alpha1
    kind: SkyProvider
    metadata:
      name: sky-provider-test1
      namespace: skytest
      labels:
        skycluster.io/managed-by: skycluster

        # This is part of internal settings and users do not 
        # need to set this.
        # skycluster.io/provider-name: os
        # skycluster.io/provider-region: SCINET
        # skycluster.io/provider-zone: default

        # Often there is a need to use existing external resources
        # such as a public network, an existing router, etc.
        # You can specify the external resource ID using 
        # the following labels:
        # skycluster.io/ext-Kind-Group-Version: <resource-name>
        # Due to the annotation key length limit, we only use 
        # the first word of the api group. 
        # This approach prevents creating, modifying or deleting 
        # the resource group by SkyCluster. However, SkyCluster 
        # pull resource group information and use them when 
        # creating other resources.

        # For Azure, for instance, you can specify the resource group:
        # skycluster.io/ext-ResourceGroup-azure-v1beta1: skycluster-manual

        # For OpenStack providers, SkyCluster does not support creating 
        # a public (external) network.
        # The network should exist before creating the provider.
        # Use the label below to specify the external network name:
        # skycluster.io/ext-os-public-subnet-name: ext-net
        
        # Other examples:
        # skycluster.io/ext-ProjectV3-identity-v1alpha1: 1e1c7...3ddc8f30b
        # skycluster.io/ext-RouterV2-networking-v1alpha1: 0033d21...6153167017
    spec: 
      forProvider:
        # For openstack, we get the subnet cidr, typically in the form of
        # x.y.z.0/24, and we manually assign the network cidr to x.y.0.0/16
        # Currently, this is the only swttings we support
        vpcCidr: 10.80.10.0/24
        gateway: {}
          # flavor: large
          # If public key is not provided, a new keypair using SkyCluster keypair secret
          # will be created. This secert should be generated during the configuration of
          # the SkyCluster.
          # publicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQz3
        # You can omit the vpnServer section if the secret containing the overley data
        # is already created, otherwise you need to provide all fields within the vpnServer section
        # vpnServer:
        #   host: http://vpnserver.com
        #   port: 443
        #   token: 123df456
        #   ca_cert: base64 encoded string of the ca.crt content
      providerRef:
        # Provider name can be any of the supported providers
        # Currently, we support aws, gcp, azure and os (openstack)
        providerName: os
        providerRegion: <RegionName>
        providerZone: <ZoneName>


.. container:: toggle

  .. container:: header 

    **skyprovider-example.sh**
  
  .. code-block:: yaml
    :linenos:

    apiVersion: xrds.skycluster.io/v1alpha1
    kind: SkyProvider
    metadata:
      name: skyprovider-test102
      namespace: skytest
      labels:
        skycluster.io/managed-by: skycluster
        # the following labels should be added internally
        skycluster.io/provider-name: aws
        skycluster.io/provider-region: us-east-1
        skycluster.io/provider-zone: use1-az1
    spec: 
      forProvider:
        vpcCidr: 10.30.185.0/24
      providerRef:
        providerName: aws
        providerRegion: us-east-1
        providerZone: use1-az1


SkyVM Object
===============

``SkyVM`` is a virtual machine that can be deployed  
across any of the registered providers by specifying the ``providerRef`` object. 


.. container:: toggle open

  .. code-block:: yaml
    :linenos:
    :emphasize-lines: 1

    apiVersion: xrds.skycluster.io/v1alpha1
    kind: SkyVM
    metadata:
      name: skyvm-test-1018
      namespace: skytest
      labels:
        skycluster.io/managed-by: skycluster
        # the following labels should be added internally
        skycluster.io/provider-name: <ProviderName>
        skycluster.io/provider-region: <RegionName>
        skycluster.io/provider-zone: <ZoneName>
    spec: 
      forProvider: 
        # Or you can specify the VM size and image:
        flavor: 1vCPU-2GB # 2vCPU-2GB, 4vCPU-8GB, ...
        image: ubuntu-22.04 # ubuntu-20.04, ubuntu-18.04
        
        userData: |
          #cloud-config
          runcmd:
            - echo "Hello, World!" > /tmp/hello.txt 
        
        # If publicIp is set to true, a public IP is assigned to the VM
        # For openstack provider, ensure the annotation
        # "skycluster.io/ext-os-public-subnet-name" is set to the public subnet name
        publicIp: true
        
        # You can create a new keypair exclusively for this VM 
        # by providing the public key. If it is not provided,
        # the default skycluster keypair is used.
        publicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD
        
        # If set IP forwarding is enabled for the node depending on the provider type
        # For openstack provider, setting a security group 
        # makes IP forwarding impossible. Hence, the security group is not applied
        # if IP forwarding is enabled.
        iPForwarding: false

        # You can create a custom security group for this VM
        secGroup:
          description: "Allow SSH and HTTP"
          tcpPorts:
            - fromPort: 22
              toPort: 22
            - fromPort: 80
              toPort: 80
          udpPorts: []
        
      providerRef:
        # Provider name can be any of the supported providers
        # Currently, we support aws, gcp, azure and os (openstack)
        providerName: <ProviderName>
        providerRegion: <RegionName>
        providerZone: <ZoneName>


``flavor`` specifies the type of VM to be created. The abstracted flavors are 
introduced in the helm charts during the installation SkyCluster. 
You can get a list of available flavors across providers by using ``skycluster`` cli tool:

.. code-block:: sh

  # Listed all available flavors across aws, azure and gcp
  skycluster skyvm flavor list --provider-name aws,gcp,azure

``image`` specifies the image to be used for the VM. Like flavors, the abstracted images are 
introduced in the helm charts during the installation SkyCluster. 
You can get a list of available images across providers by using ``skycluster`` cli tool:

.. code-block:: sh

  # Listed all available images across aws, azure and gcp
  skycluster skyvm image list --provider-name aws,gcp,azure



.. container:: toggle 

  .. container:: header 

    **skyvm-example.sh**
  
  .. code-block:: yaml
    :linenos:

    apiVersion: xrds.skycluster.io/v1alpha1
    kind: SkyVM
    metadata:
      name: skyvm-test102
      namespace: skytest
      labels:
        skycluster.io/managed-by: skycluster
        # the following labels should be added internally
        skycluster.io/provider-name: aws
        skycluster.io/provider-region: us-east-1
        skycluster.io/provider-zone: use1-az1
    spec: 
      forProvider: {}
      providerRef:
        providerName: aws
        providerRegion: us-east-1
        providerZone: use1-az1


SkyK8SCluster Object
====================

SkyK8S is a virtual Kubernetes cluster which can be deployed geographically distributed across
multiple cloud providers. We optimize the deployment of node pools across multiple cloud providers.
So you need to specify the data flow and location constraints for each node pool.
The node instances within each node pool is determined by minimum and max number of nodes
and location and quality constraints.

.. container:: toggle open

  .. container:: header open

    **skyk8s-example.sh**

  .. code-block:: yaml
    :emphasize-lines: 14,18,23-26,59,60,70
    :linenos:

    apiVersion: xrds.skycluster.io/v1alpha1
    kind: SkyK8SCluster
    metadata:
      labels:
        skycluster.io/managed-by: skycluster
      name: my-skyk8s-1
    spec:
      forProvider:
        # If you are using a private registry, you can specify the private registry
        # We don't support private registry with secret yet.
        privateRegistry: registry.skycluster.io
        agents:
        - name: agent-sci-1
          flavor: 4vCPU-16GB
          image: ubuntu-22.04
          providerRef:
            providerName: os
            providerRegion: SCINET
            providerZone: default
        - name: agent-va-1
          flavor: 4vCPU-16GB
          image: ubuntu-22.04
          providerRef:
            providerName: os
            providerRegion: VAUGHAN
            providerZone: default
        ctrl:
          flavor: 8vCPU-32GB
          image: ubuntu-22.04
          providerRef:
            providerName: os
            providerRegion: SCINET
            providerZone: default
          
        # [Auto scalling functionally is not yet supported.]
        # "autoscaling" enables scalling of the nodes in 
        # this node pool. Not implemented yet.
        autoscaling:
          # The minimum and maximum number of nodes is used to ensure 
          # The number of nodes in the pool is within the specified range
          minCount: 3
          maxCount: 5
          metrics:
            # Custom metrics should be specified as part of services within
            # the cluster using the post-setup application configuration
            - type: Metric
              metric:
                endpoint: my-svc/k8s-metrics
                target: 50  


