Multi Provider Setup
#######################

.. toctree::
  :hidden:

Make sure you have followed steps in :doc:`/getting-started/index` and ensure all  
prerequisites installed and configured, including:

- :doc:`/getting-started/providers-auth`
- :doc:`/getting-started/providers-profile`
- :doc:`/getting-started/skycluster-configs`
- :doc:`/examples/single-provider`

At this stage, you should have multiple providers created and ready for use. Check out you providers by:

.. code-block:: sh

    skycluster xprovider list
    # NAME                  PRIVATE_IP      PUBLIC_IP        CIDR_BLOCK
    # os-provider-scinet    10.16.128.11    142.1.174.185    10.16.0.0/16


From the SkyCluster controller and across all providers, you should be able to reach the services and resources created within the CIDR block of each provider. This resembles a flat network setup created by SkyCluster. Try pinging the private gateway address of each provider from the SkyCluster controller to verify connectivity. Check the :doc:`/getting-started/troubleshooting` page if you encounter any issues.


Multi-cluster Kubernetes Cluster 
==================================

To connect Kubernetes clusters an ``XKubeMesh`` resource must be created. This resource manages inter-cluster connectivity by linking each cluster and configuring the Istio setup.

.. code-block:: yaml
  
    apiVersion: skycluster.io/v1alpha1
    kind: XKubeMesh
    metadata:
      name: my-kubemesh
    spec: 
      # Reference to xkubes.skycluster.io resources
      clusterNames:
        - example-kube-os-scinet
        - ex1-kube-gcp
        - ex1-aws-kube

      # The local kind cluster config that used for skycluster controller setup  
      localCluster:        
        podCidr: 10.0.0.0/19
        serviceCidr: 172.31.0.0/16

Check out the status of inter-cluster connectivity by running:

.. code-block:: sh

  kubectl get xkubemeshes.skycluster.io
  # NAME       SYNCED   READY   COMPOSITION                 AGE
  # kubemesh   True     True    xkubemeshes.skycluster.io   4h41m

