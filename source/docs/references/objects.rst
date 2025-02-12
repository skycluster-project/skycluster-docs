.. toctree::
  :hidden:


Primary Objects
###############




SkyProvider Object
==================

``SkyProvider`` is an object that represents a cloud provider.
By creating a SkyProvider object, the minimum setup and configuration
required to deploy virtual services on the cloud provider is done.

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
          # flavor: small
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
        flavor: small/medium/large/xlarge
        image: ubuntu-22.04/ubuntu-20.04/ubuntu-18.04
        
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


SkyK8S Object
===============

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

    apiVersion: skycluster.io/v1alpha1
    kind: SkyK8S
    metadata:
      labels:
        skycluster.io/managed-by: skycluster
      name: my-skyk8s-1
    spec:

      # If multicluster is set to true, each node pool forms 
      # a separate cluster. A multi-cluster k8s is formed by joining
      # multiple clusters.
      # If multicluster is set to false, a single cluster spans 
      # across all nodes. Currently, only single cluster is supported.
      enableMultiCluster: false
      
      # An array of configuration for each node pool can be specified
      # All nodes in this pool share the same configuration
      nodePools:
        
        # You can distinguish the controller node by setting controller 
        # field to true. If no node pool is specified with controller 
        # set to true, a controller node is created from the first node pool
        - controller: true
          machineType: n1-standard-2
          diskSizeGb: 100
          diskType: pd-ssd
          
          # The controller cannot be preemptible and
          # this option only applies to agent nodes.
          # If an agent node is terminated, the skycluster tries to 
          # recreate the node given the constraints and configurations.
          # This option is not implemented yet.
          preemptible: false
          
          # Auto scalling functionally enables scalling of the nodes in 
          # this node pool. Not implemented yet.
          autoscaling:
            # The minimum and maximum number of nodes is used to ensure 
            # The number of nodes in the pool is within the specified range
            minCount: 3
            maxCount: 5
            metrics:
              - type: Resource
                resource:
                  name: cpu
                  targetAverageUtilization: 50
              - type: Resource
                resource:
                  name: memory
                  targetAverageUtilization: 50
              # Custom metrics should be specified as part of services within
              # the cluster using the post-setup application configuration
              - type: Metric
                metric:
                  endpoint: /k8s-metrics
                  target: 50

          # For each node pool, you can specify the location constrains 
          locationConstraints:
            permitted:
              - name: us-central1-a-edge
                region: us-central1
                regionAlias: us-central1
                regionType: Edge
                # When all fields are set, the intersection of the fields is used
              - region: us-east
                regionType: Edge
              # When nmultiple permitted fields are set, 
              # the union of the fields is used
            required:
              - name: us-central1-a-edge-12345
                # Same as permitted, when multiple fields are set, 
                # the intersection of them is used
              - regionAlias: us-east1
                regionType: Edge
              # Same as permitted, when multiple required fields are set,
              # the union of the fields is used    




SkyOverlay Object
=================

``SkyOverlay`` is an overlay vpn solution that enables point to point 
communication and routing between virtual services across multiple providers.

.. container:: toggle open

  .. container:: header open

    **skyoverlay-example.sh**

  .. code-block:: yaml
    :linenos:

    apiVersion: skycluster.io/v1alpha1
    kind: SkyOverlay
    metadata:
      labels:
        skycluster.io/managed-by: skycluster
      name: my-skyoverlay-1
    spec:
      rendezvousAddress: 100.24.214.22:9586
      rendezvousToken: 1234567890
      providersRef:
        - name: us-central1-a-edge-12345
        - name: us-east1-a-edge-34212
        - name: eu-central1-cloud-95843

SkyOverlayGateway Object
=========================

.. container:: toggle open

  .. container:: header open

    **skyoverlaygw-example.yaml**

  .. code-block:: yaml
    :linenos:

    apiVersion: skycluster.io/v1alpha1
    kind: SkyOverlayGateway
    metadata:
      name: my-skyoverlaygw-1
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/type: ssh-key
    spec:
      rendezvousAddress: 100.24.214.22:9586
      rendezvousToken: 1234567890
      providersRef:
        - name: us-central1-a-edge-12345
        - name: us-east1-a-edge-34212
        - name: eu-central1-cloud-95843

SkyOverlayClient Object
=======================

.. container:: toggle open

  .. container:: header open

    **skyoverlayclient-example.yaml**

  .. code-block:: yaml
    :linenos:

    apiVersion: skycluster.io/v1alpha1
    kind: SkyOverlayClient
    metadata:
      labels:
        skycluster.io/managed-by: skycluster
      name: my-skyoverlayclient-1
    spec:
      rendezvousAddress: 100.24.214.22:9586
      rendezvousToken: 1234567890
      providersRef:
        - name: us-central1-a-edge-12345
        - name: us-east1-a-edge-34212
        - name: eu-central1-cloud-95843

