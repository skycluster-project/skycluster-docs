
Multi-Provider Example
-----------------------------------

Now let's look at an example of setting up a multi-cloud environment using SkyCluster. In this example, we will provision resources across AWS and GCP providers with inter-cluster connectivity.

Virtual machines
^^^^^^^^^^^^^^^^^^^^^^

You can create virtual machines across multiple providers as described above. There is no additional configuration needed since SkyCluster automatically sets up the overlay network across all providers. You have reachability between VMs across different providers using the private IPs.

Kubernetes clusters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You can create Kubernetes clusters across multiple providers as described above. To enable reachability between pods and services across different providers, you need to follow these additional steps.

  **Prerequisites:**

  - Ensure there are at least two providers set up in your SkyCluster environment.
  - Ensure you have created Kubernetes clusters on each provider as described above.

Once you have at least two Kubernetes clusters, try activate the inter-cluster connectivity feature:

.. code-block:: sh

  # Start by cleaning up any previous inter-cluster setup 
  skycluster cleanup

  # Enable inter-cluster connectivity between all existing Kubernetes clusters
  skycluster xkube mesh --enable
  # Enabling interconnect... updated xkubemesh/xkube-cluster-mesh (clusterNames: 2)
  # Enabling interconnect... done
  

At this point, all your Kubernetes clusters should be able to reach each other. You can verify this by deploying test pods in each cluster and checking connectivity using ping or curl commands.

Congratulations! You have successfully set up a multi-cloud environment using SkyCluster. You can now deploy your applications across multiple cloud providers and take advantage of the unified management plane provided by SkyCluster. 

Please refer to the :doc:`examples </examples/index>` section for more advanced use cases and application deployments.