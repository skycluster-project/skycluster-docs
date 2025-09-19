Providers Profiles
#######################

.. toctree::
  :hidden:


Setting Up Cloud Providers
=============================

A provider is identified by its platform name and region and primary zone. To integrate a provider, you need to create a `ProviderProfile` resource in the SkyCluster system. The following examples show how to configure the a ``ProfileProvider`` for the major cloud providers: AWS, GCP, and Azure.

.. tabs::

  .. tab:: AWS

      .. code-block:: yaml

        apiVersion: core.skycluster.io/v1alpha1
        kind: ProviderProfile
        metadata:
          name: aws-us-east-1
        spec:
          platform: aws # Platform can be aws, azure, gcp
          region: us-east-1  # Region identifier
          regionAlias: us-east
          continent: north-america
          enabled: true
          zones:
            - name: us-east-1a   # Zone identifier
              locationName: us-east-1a
              defaultZone: true # Only one zone can be default
              enabled: true
              type: cloud  # Optional
            - name: us-east-1b    # Zone identifier
              locationName: us-east-1b
              defaultZone: false
              enabled: true
              type: cloud  # Optional


  .. tab:: GCP

      .. code-block:: yaml

        apiVersion: core.skycluster.io/v1alpha1
        kind: ProviderProfile
        metadata:
          name: gcp-us-east1
        spec:
          platform: gcp # Platform can be aws, azure, gcp
          region: us-east1  # Region identifier
          regionAlias: us-east
          continent: north-america
          enabled: true
          zones:
            - name: us-east1-b   # Zone identifier
              locationName: us-east1-b
              defaultZone: true # Only one zone can be default
              enabled: true
              type: cloud  # Optional
            - name: us-east1-c    # Zone identifier
              locationName: us-east1-c
              defaultZone: false
              enabled: true
              type: cloud  # Optional


  .. tab:: Azure

      .. warning::
        Azure support is limited and some features may not work.

      .. code-block:: yaml

        apiVersion: core.skycluster.io/v1alpha1
        kind: ProviderProfile
        metadata:
          name: azure-eastus
        spec:
          platform: azure # Platform can be aws, azure, gcp
          region: eastus  # Region identifier
          regionAlias: eastus
          continent: north-america
          enabled: true
          zones:
            - name: "1"   # Zone identifier
              locationName: eastus-1
              defaultZone: true # Only one zone can be default
              enabled: true
              type: cloud  # Optional
            - name: "2"    # Zone identifier
              locationName: eastus-2
              defaultZone: false
              enabled: true
              type: cloud  # Optional


SkyCluster automatically detects available images and instance types for major cloud providers such as ``AWS``, ``Azure``, and ``GCP``. For ``OpenStack`` and ``baremetal``, these services must be configured manually

After creating a ``ProfileProvider`` resource, the SkyCluster operator generates a ConfigMap in the ``skycluster-system`` namespace containing the available images and instance types for that provider. Verify that the provider profile is ready by checking its status:

.. code-block:: sh

  kubectl get providerprofile
  # NAME            REGION      READY
  # aws-us-east-1   us-east-1   Ready


Setting Up On-premises Providers
====================================


OpenStack
^^^^^^^^^^^^^

Similar to cloud provider, a edge or private provider is identified by its platform name and region 
and primary zone. In addition to ``ProfileProvider`` resource, you also need to create dependency 
resources to for the provider. The following example shows how to configure the OpenStack 
provider for the on-premises ``savi`` edge cluster with ``scinet`` region with primary zone ``default``.


Provider Profiles
---------------------------------

.. code-block:: yaml

    apiVersion: core.skycluster.io/v1alpha1
    kind: ProviderProfile
    metadata:
      name: savi-scinet-default
    spec:
      platform: openstack
      region: scinet
      regionAlias: scinet # Optional
      continent: north-america # Optional
      enabled: true
      zones:
        - name: default
          locationName: default # Optional
          defaultZone: true
          enabled: true
          type: edge


.. note::

  ``ProviderProfile`` status becomes ``Ready`` when the dependency resources are created for the provider. Check out 
  the status of the ``ProviderProfile`` resource by running the following command. You should see the ``Ready`` 
  status set to ``False`` when you create the object for the first time. It will change to ``True`` once the 
  dependency objects are created.

  .. code-block:: sh

    kubectl get providerprofile
    # NAME                  REGION      READY
    # savi-scinet-default   scinet      False

The operator creates a config map for each provider profile that constains offerings by the provider. You can verify the config map by running the following command:

.. code-block:: sh

  kubectl get configmap -n skycluster-system \
    -l skycluster.io/provider-profile=savi-scinet-default


Dependency Resources 
---------------------------------------

The following dependency resources are needed to 
ensure ``ProviderProfile`` becomes ready and can be used:

Images 
********

You need to configure the available images **manually** for on-premises providers. 
The following example shows how to configure images including ``ubuntu-20.04``, ``ubuntu-22.04`` and ``ubuntu-24.04`` for the ``savi-scinet-default`` provider profile for the ``scinet`` region.

.. code-block:: yaml

  apiVersion: core.skycluster.io/v1alpha1
  kind: Image
  metadata:
    name: savi-scinet-default-images
  spec:
    providerRef: savi-scinet-default
    # Must match the provider profile name in the Provider resource

    images:
      - zone: default
        nameLabel: ubuntu-20.04
        name: ubuntu-20.04 # Local identifier corresponding to the image
      - zone: default
        nameLabel: ubuntu-22.04
        name: ubuntu-22.04 # Local identifier corresponding to the image
      - zone: default
        nameLabel: ubuntu-24.04
        name: ubuntu-24.04 # Local identifier corresponding to the image

Check the status of ``Image`` resource by running the following command:

.. code-block:: sh

    kubectl get images.core.skycluster.io
    # NAME                         REGION      READY
    # savi-scinet-default-images   scinet      True

Instance Type
**************

To configure the instance types, you need to create an ``InstanceType`` resource. The following example shows how to introduce available instance types. 

.. code-block:: yaml

  apiVersion: core.skycluster.io/v1alpha1
  kind: InstanceType
  metadata:
    name: savi-scinet-default-instance-types
  spec:
    providerRef: savi-scinet-default
    # Must match the provider name in the Provider resource

    offerings:
      - zone: default
        zoneOfferings:
          - name: m1.small
            nameLabel: 1vCPU-2GB
            price: "0.0015"
            ram: 2GB
            vcpus: 1
          - name: n1.small
            nameLabel: 1vCPU-4GB
            vcpus: 1
            ram: 4GB
            price: "0.02"

Check the status of the ``InstanceType`` resource by running the following command:

.. code-block:: sh

    kubectl get instancetype.core.skycluster.io
    # NAME                                 REGION      READY
    # savi-scinet-default-instance-types   scinet      True


Once all dependency resources are created and ready, the ``ProviderProfile`` status changes to ``Ready``. At this point, you can use the provider profile to create resources in your cluster. To verify its status, run:

.. code-block:: sh

    kubectl get providerprofile
    # NAME                  REGION      READY
    # savi-scinet-default   scinet      True



On-premises Custom Providers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On-premises providers can be registered similarly to cloud providers but you must also create ``DeviceNode`` resources to supply on-premises configuration such as the gateway node address, required keys, and edge-device details.


Provider Profiles
---------------------------------

.. code-block:: yaml

    apiVersion: core.skycluster.io/v1alpha1
    kind: ProviderProfile
    metadata:
      name: savi-toronto-default
    spec:
      platform: baremetal
      region: toronto
      regionAlias: toronto # Optional
      continent: north-america # Optional
      enabled: true
      zones:
        - name: default
          locationName: BahenBuilding # Optional
          defaultZone: true
          enabled: true
          type: edge


The ``baremetal`` type requires specifying gateway connection and access details, along with worker node data and their capabilities. You must configure this by creating ``DeviceNode`` resources:

Device Nodes
-------------

The ``DeviceNode`` API represents an edge device that can run workloads. A DeviceNode resource can be defined as either a gateway or a worker node by setting its ``type`` field. By default the gateway node does not run any workload.

.. tabs::

  .. tab:: Gateway

      .. code-block:: yaml

        apiVersion: core.skycluster.io/v1alpha1
        kind: DeviceNode
        metadata:
          name: savi-toronto-gw
        spec:
          providerRef: savi-toronto-default
          deviceSpec:
            type: gateway
            zone: default
            
            publicIp: x.y.z.w

            # by default the subnet mask is /24 for this network
            privateIp: 10.23.100.22
            
            auth:
              privateKeySecretRef:
                # secret containing the private SSH key, see below
                name: savi-toronto-edge-ssh-key
                key: privateKey
              username: ubuntu

  .. tab:: Worker

      .. code-block:: yaml

        apiVersion: core.skycluster.io/v1alpha1
        kind: DeviceNode
        metadata:
          name: savi-toronto-edge-jetson-nano1
        spec:
          providerRef: savi-toronto-edge
          deviceSpec:
            type: worker
            zone: default

            privateIp: 10.23.100.200
            # must be reachable from the gateway node
            
            auth:
              username: ubuntu
              # same private key as the gateway node will be used
            
            configs:
              name: Jetson Nano
              cpus: 1
              ram: 4GB
              gpu: 
                count: 472
                unit: GFLOPS # GFLOPS | TFLOPS | TOPS | GPU
                enabled: true
                manufacturer: NVIDIA
                memory: Maxwell
                model: JetsonNano
              storage: 100GB
              price: "0"
