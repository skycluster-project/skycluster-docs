Clean up the environment
=============================


To clean up all resources created by SkyCluster, run the following command:

.. code-block:: sh
  
  # Disable inter-cluster connectivity first
  skycluster mesh --disable

  # Clean up all resources created by SkyCluster
  skycluster xkube list
  skycluster xkube delete -n <cluster-name>

  skycluster xprovider list
  skycluster xprovider delete -n <provider-name>

  # Finally, run the cleanup command to remove any remaining
  # configurations
  skycluster cleanup
