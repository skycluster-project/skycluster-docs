.. toctree::
  :hidden:


Primary Objects
###############

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


SkyVM Object
===============

``SkyVM`` is a virtual machine that can be deployed geographically distributed 
across multiple cloud providers. Each SkyVM object has its specifications and it
receive a provider reference so that it will be placed in the specified location.

.. container:: toggle open

  .. container:: header open

    **skyfleet-example.sh**

  .. code-block:: yaml
    :linenos:

    apiVersion: skycluster.io/v1alpha1
    kind: SkyVM
    metadata:
      labels:
        skycluster.io/managed-by: skycluster
      name: my-skyvm-1
    spec:
      machineType: n1-standard-2
      diskSizeGb: 100
      diskType: pd-ssd
      preemptible: false
      image: ubuntu:20.04

      # for monitoring purposes, not implemented yet.
      metrics:
        - type: Resource
          resource:
            name: cpu
        - type: Resource
          resource:
            name: memory
        # Custom metric that should be accessible using VM IP address
        # ex. <protocol>://<vm-ip>:<port>/vm-metrics
        - type: Metric
          metric:
            endpoint: /vm-metric
            port: 9040
            protocol: http
      providerRef:
        name: us-central1-a-edge-12345




SkyOverlay Object
===============

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
===============

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
===============

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



SkyProvider Object
===============

``SkyProvider`` is an object that represents a cloud provider.
By creating a SkyProvider object, the minimum setup and configuration
required to deploy virtual services on the cloud provider is done.

.. container:: toggle open

  .. container:: header open

    **skyprovider-example.sh**

  .. code-block:: yaml
    :linenos:

    apiVersion: skycluster.io/v1alpha1
    kind: SkyProvider
    metadata:
      labels:
        skycluster.io/managed-by: skycluster
      name: my-skyprovider-1
    spec:
      publicKey: |
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9Zz5zZz5zZz5zZz5
      ipCidrRange: 100.12.42.0/24
      secgroup: 
        - name: default
          tcpPorts:
            - fromPort: 22
              toPort: 22
          udpPorts:
            - fromPort: 53
              toPort: 53
      providersRef:
        - name: us-central1-a-edge-12345
        - name: us-east1-a-edge-34212
        - name: eu-central1-cloud-95843
        # or separate object for each provider?



