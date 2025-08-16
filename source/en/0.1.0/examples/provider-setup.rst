Provider Setup
####################

.. toctree::
  :hidden:

To initialize a provider, you need to introduce credentials and create a profile to setup specified regions and zones. Once a profile is created, SkyCluster the provider profile will be on board for service configuration and management. If the profile is for one of the big three cloud providers (AWS, Azure, GCP), SkyCluster will automatically pull images and instance types from the provider's API.


Step 1: Create a ProviderProfile
----------------------------------

To create a provider profile, you can use the following YAML configuration to create a `ProviderProfile` object.

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


Step 2: Image and Instance Types
---------------------------------

``Image`` and ``InstanceType`` are automatically pulled from the provider's available images and instance types for the specified region and zone. This data is used to create underlying virtual machines where it is required. For major cloud providers, SkyCluster will automatically fetch the images and instance types from the provider's API once you create these objects for each ``ProviderProfile`` you created in the previous step.


