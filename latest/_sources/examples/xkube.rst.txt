
Managed Kubernetes Cluster 
#############################

.. toctree::
  :hidden:


Now let's create a managed Kubernetes cluster using the provider instance we just created. We use same ``XKube`` resource for different cloud providers. However, a few parameters must be adjusted based on the provider requirements.

.. tabs::

  .. tab:: AWS EKS

      .. code-block:: yaml

        apiVersion: skycluster.io/v1alpha1
        kind: XKube
        metadata:
          name: ex1-aws-kube
        spec:
          
          applicationId: aws-us-east
          serviceCidr: 172.16.0.0/16
          
          podCidr: 
            cidr: 10.16.128.0/17
            public: 10.16.128.0/18	
            private: 10.16.192.0/18	
          
          nodeGroups:
          - instanceType: "2vCPU-4GB"
            publicAccess: true
            autoScaling: 
              enabled: false
              minSize: 1
              maxSize: 1
            
          principal:
            type: servicePrincipal # user | role | serviceAccount | servicePrincipal | managedIdentity
            id: "arn:aws:iam::8857123199:root" # ARN (AWS) | member (GCP) | principalId (Azure)
          
          providerRef:
            platform: aws
            region: us-east-1
            zones:
              primary: us-east-1a
              secondary: us-east-1b


  .. tab:: GCP GKE

      .. code-block:: yaml

        apiVersion: skycluster.io/v1alpha1
        kind: XKube
        metadata:
          name: ex1-kube-gcp
        spec:
          
          applicationId: gcp-us-east1
          
          nodeCidr: 10.17.128.0/17 # GKE requires a node CIDR range
          
          podCidr: 
            cidr: 172.17.0.0/16
          
          # There is a default node pool created by GKE with one node
          nodeGroups: 
          - nodeCount: 2
            instanceType: 2vCPU-4GB
            publicAccess: false
            autoScaling:
              enabled: true
              minSize: 1
              maxSize: 4
          
          providerRef:
            platform: gcp
            region: us-east1
            zones:
              primary: us-east1-b


  .. tab:: OpenStack (K3S)

      .. code-block:: yaml

        apiVersion: skycluster.io/v1alpha1
        kind: XKube
        metadata:
          name: ex1-kube-os-scinet
        spec:
          
          applicationId: os-scinet
          
          serviceCidr: 10.15.192.0/18
          
          podCidr: 
            cidr: 10.15.64.0/18
          
          controlPlane:
            instanceType: 8vCPU-32GB
            # autoScaling:
            #   enabled: true
            #   minSize: 1
            #   maxSize: 3
            # highAvailability: true

          nodeGroups:
          - instanceType: "4vCPU-4GB"
            publicAccess: false
            autoScaling: 
              enabled: false
              minSize: 1
              maxSize: 1
            
          providerRef:
            platform: openstack
            region: SCINET
            zones:
              primary: default


.. note::

  You can determine the appropriate CIDR size for your provider by using the ``skycluster`` 
  CLI commands and provide the VPC CIDR.

  .. container:: toggle 

    .. container:: header

      **Example:**

    .. code-block:: sh

      skycluster subnet 10.16.0.0/16 -p aws
      #     NAME                             CIDR
      # └── VPC                          10.16.0.0/16
      #     ├── Subnet Range             10.16.0.0/17
      #     └── XKube Pod Range (EKS)    10.16.128.0/17
      #         ├── Primary              10.16.128.0/18
      #         └── Secondary            10.16.192.0/18
      # └── XKube Service Range (EKS)    172.16.0.0/16

.. note::

  Check the status of the ``XKube`` instance by running the following command or through :doc:`/getting-started/skycluster-dashboard`.

  .. code-block:: sh

    kubectl get xkubes.skycluster.io
    # NAME                          SYNC     STATUS
    # example-instance-us-east      Ready    Ready

  You can also use the SkyCluster cli commadnd:

  .. code-block:: sh

    skycluster xkubes list 


Once you initialize and set up a provider, you can create additional ``XProvider`` resources to integrate other cloud providers such as GCP and Azure. When you have more than two providers configured, you are ready to follow the multi-provider examples. 

For GCP GKE service:

.. code-block:: sh

  skycluster xkubes list 
  # note gcp cluster with external name

  # use gcloud to setup kubeconfig
  gcloud container clusters get-credentials <external-name> --location <location>

  # please refer to 
  # https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl