Providers Registration
#######################

.. toctree::
  :hidden:


Setting Up Cloud Providers
=============================

A provider is identified by its platform name and region and primary zone. To integrate a provider, you need to create a `Provider` resource in the SkyCluster system. The following example shows how to configure the ``us-east-1`` region with primary zone ``us-east-1a`` and secondary zone ``us-east-1b``. 

.. code-block:: yaml

  apiVersion: core.skycluster.io/v1alpha1
  kind: Provider
  metadata:
    name: aws-us-east-1
  spec:
    platform: aws
    region: us-east-1
    regionAlias: us-east # Optional
    continent: north-america # Optional
    enabled: true
    zones:
      - name: us-east-1a
        locationName: us-east-1a # Optional
        defaultZone: true
        enabled: true
        type: cloud
      - name: us-east-1b
        locationName: us-east-1b # Optional
        defaultZone: false
        enabled: true
        type: cloud


SkyCluster automatically detects the images and instance types available for the specified provider and region for major cloud providers including ``AWS``, ``Azure``, ``GCP``. For ``OpenStack`` and ``Other`` providers, you need to manually configure the available services.

Setting Up Images and Instance Types
---------------------------------------

You need to configure the available images and instance types for your provider. For ``AWS``, ``Azure``, and ``GCP``, this is done automatically by creating ``Image`` and ``InstanceType`` resources. The following example shows how to configure images including ``ubuntu-22.04`` and ``ubuntu-24.04`` for the ``aws-us-east-1`` provider for the ``us-east-1a`` and ``us-east-1b`` zones.

.. code-block:: yaml

  apiVersion: core.skycluster.io/v1alpha1
  kind: Image
  metadata:
    name: aws-us-east-1
  spec:
    providerRef: aws-us-east-1
    # Must match the provider name in the Provider resource

    zones:
      - nameLabel: ubuntu-22.04
        zone: us-east-1a
      - nameLabel: ubuntu-24.04
        zone: us-east-1a
      - nameLabel: ubuntu-22.04
        zone: us-east-1b
      - nameLabel: ubuntu-24.04
        zone: us-east-1b

The operator creates a config map for each provider that contains the available images offered by the provider. 

To configure the instance types, you need to create an ``InstanceType`` resource. The following example shows how to get available instance types for the ``aws-us-east-1`` provider. SkyCluster operator automatically detects the available instance types from ``t3*``, ``t4*``, ``m5*``, ``m6*``, ``g4*``, ``g5*``, ``p3*``, ``p4*`` instance families.

.. code-block:: yaml

  apiVersion: core.skycluster.io/v1alpha1
  kind: InstanceType
  metadata:
    name: aws-us-east-1
  spec:
    providerRef: aws-us-east-1
    # Must match the provider name in the Provider resource

The images and types data are stored in the ``skycluster-system`` namespace in the ``<platform>.<region>.<zone>`` config map. 


.. warning::

  ``GCP`` and ``Azure`` providers are not yet supported in the current version of SkyCluster. The above examples are for ``AWS`` only.



OpenStack Configuration
========================

For on-premises OpenStack providers, you need to create a `ProviderConfig` resource that contains the OpenStack data. The following example shows how to configure the OpenStack provider for the on-premises ``savi`` edge cluster with ``scinet`` region with primary zone ``default``.

.. code-block:: yaml

    apiVersion: core.skycluster.io/v1alpha1
    kind: Provider
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

Create a mapping file with the available images and instance types for the OpenStack provider. The following example shows how to configure the images and flavors for the ``savi-scinet-default`` provider:


.. code-block:: yaml
    :linenos:

    # images.yaml
    zones:
    - name: ubuntu-22.04
      nameLabel: ubuntu-22.04
      zone: default
    - name: ubuntu-24.04
      nameLabel: ubuntu-24.04
      zone: default 

.. code-block:: yaml
    :linenos:

    # instance-types.yaml
    - flavors:
      - name: m1.medium
        nameLabel: 2vCPU-4GB
        price: "0.0045"
        ram: 4GB
        vcpus: 2
        volumeTypes: # Optional
        - gp3
        gpu: # Optional
          count: 0
          enabled: false
          manufacturer: ""
          memory: 0GB
          model: ""
        spot: # Optional
          enabled: false
          price: "-1"
      - name: o1.medium
        nameLabel: 2vCPU-16GB
        price: "0.0045"
        ram: 16GB
        vcpus: 2
      - name: p1.medium
        nameLabel: 2vCPU-32GB
        price: "0.0045"
        ram: 32GB
        vcpus: 2
      - name: p1.large
        nameLabel: 4vCPU-8GB
        price: "0.0045"
        ram: 8GB
        vcpus: 4
      - name: p3.large
        nameLabel: 4vCPU-32GB
        price: "0.0045"
        ram: 32GB
        vcpus: 4
      - name: m5.large
        nameLabel: 4vCPU-32GB
        price: "0.0045"
        ram: 32GB
        vcpus: 4
      - name: m2.xlarge
        nameLabel: 8vCPU-32GB
        price: "0.0045"
        ram: 32GB
        vcpus: 8


Then create a config map for the OpenStack provider with the images and flavors data. The following example shows how to create the config map for the ``savi-scinet-default`` provider:

.. code-block:: sh

    kubectl create cm savi.scinet.default -n skycluster-system \
      --from-file=images.yaml \
      --from-file=instance-types.yaml | kubectl apply -f -

    # Label the config map 
    kubectl label cm savi.scinet.default -n skycluster-system \
      skycluster.io/managed-by=skycluster \
      skycluster.io/config-type=provider-settings \
      skycluster.io/provider-platform=openstack \
      skycluster.io/provider-region=scinet \
      skycluster.io/provider-zone=default

.. warning::

  Make sure to label the config map with the correct provider platform, region, and zone. The labels are used by the SkyCluster operator to identify the config map and apply the settings to the provider.