
Multi-cluster Kubernetes Cluster 
###################################

.. toctree::
  :hidden:

**Summary:** This example demonstrates how to set up multiple Kubernetes clusters across different cloud providers and connect them using SkyCluster's multi-cluster management capabilities.

Before you begin make sure you have followed steps in previous section :doc:`/examples/multi-provider` and have at least two ``XKube`` clusters deployed across different providers.

To connect Kubernetes clusters an ``XKubeMesh`` resource must be created. This resource manages inter-cluster connectivity by linking each cluster and configuring the Istio setup.

First find the cluster names using ``skycluster`` cli:

.. code-block:: sh

  skycluster xkube list
  # NAME                     LOCATION      EXTERNAL_NAME
  # example-kube-os-scinet   us-east-1a    xk-aws-us-east--4z74l-5tvkw
  # ex1-kube-gcp             us-central1   xk-gcp-us-central1--4z74l-5tvkw
  # ex1-aws-kube             us-west-1b    xk-aws-us-west--3z59k-q67rq

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
        serviceSubnet: 10.0.32.0/19

This may take a few minutes. Check out the status of inter-cluster connectivity by running:

.. code-block:: sh

  kubectl get xkubemeshes.skycluster.io
  # NAME          SYNCED   READY   COMPOSITION                 AGE
  # my-kubemesh   True     True    xkubemeshes.skycluster.io   4h41m

Once the ``XKubeMesh`` is ready, you should be able to access services deployed on any of the connected clusters from any other cluster. Any pod deployed on any of the clusters should be able to reach other pods and services running on other clusters.

You can now deploy multi-cluster applications across the connected clusters. Follow the :doc:`/examples/multi-cluster-apps` for more details on deploying multi-cluster applications using SkyCluster.