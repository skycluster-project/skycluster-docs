Examples
#########

.. toctree::
  :hidden:
  :maxdepth: 2
  
  single-provider
  multi-provider

To run the examples, you must follow steps in :doc:`/en/getting-started/index` and setup providers 
profiles and SkyCluster before creating resources and services.
This involves setting up credentials and creating a profile to define the desired regions and zones. Once a profile is created, the provider profile will be onboarded into SkyCluster for service configuration and management.

For major cloud providers (AWS, Azure, GCP), SkyCluster automatically creates additional resources, including available images and instance types. For detailed instructions, see: :doc:`/en/getting-started/providers-profile`.

In addition, ensure that the XSetup object is configured and ready in your environment. If you have not yet completed this step, refer to :doc:`/en/getting-started/skycluster-configs` for setup instructions.

.. note:: 

  Make sure both ``SYNCED`` and ``READY`` are ``True`` before proceeding with the examples:

  .. code-block:: sh

    kubectl get xsetups.skycluster.io
    # NAME        SYNCED   READY   COMPOSITION             AGE
    # mycluster   True     True    xsetups.skycluster.io   2d

  Make sure you have at least one ``ProviderProfile`` created and ``Ready``:

  .. code-block:: sh

    kubectl get providerprofiles
    # NAME                  REGION      READY
    # aws-us-east-1         us-east-1   True

  If any ``READY`` status field is not ``Ready`` check the :doc:`/en/getting-started/troubleshooting` page.


List of examples:
------------------

- :doc:`single-provider`
- :doc:`multi-provider`


