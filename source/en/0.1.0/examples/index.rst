Examples
#########

.. toctree::
  :caption: Examples
  :hidden:
  :maxdepth: 1
  
  single-provider-aws

To run the examples, you need to have the the ``XSetup`` object configured and ready in your environment. If you haven't done so, please refer to the :doc:`/en/latest/getting-started/skycluster-configs` section for instructions on how to set up your environment. 


.. warning:: 

  Make sure both ``SYNCED`` and ``READY`` are ``True`` before proceeding with the examples:

  .. code-block:: console

    kubectl get xsetups.skycluster.io


List of examples:

- :doc:`single-provider-aws`
