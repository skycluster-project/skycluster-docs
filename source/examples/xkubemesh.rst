
Multi-cluster Kubernetes Cluster 
###################################

.. toctree::
  :hidden:

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
        serviceSubnet: 10.0.32.0/19

Check out the status of inter-cluster connectivity by running:

.. code-block:: sh

  kubectl get xkubemeshes.skycluster.io
  # NAME       SYNCED   READY   COMPOSITION                 AGE
  # kubemesh   True     True    xkubemeshes.skycluster.io   4h41m

