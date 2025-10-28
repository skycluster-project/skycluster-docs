
Managed Kubernetes Cluster 
#############################

.. toctree::
  :hidden:

**Summary:** This example demonstrates how to setup and configure a Managed Kubernetes cluster within your chosen cloud provider using SkyCluster by defining an ``XKube`` resource. The ``XKube`` resource allows you to create and manage Kubernetes clusters on various cloud providers, abstracting away the complexities of cluster management.  

A managed kubernetes cluster allows you to interact with Kubernetes control plane without the need to manage the underlying nodes or infrastructure. 

.. Various approaches are used to automatically scale and provision underlying nodes based on the application workloads. 

Before you begin make sure you have followed steps in :doc:`/examples/single-provider` to prepare your provider by creating a ``XProvider`` instance. We now create ``XKube`` resource  with a few parameters adjustment based on the your ``XProvider`` setup.



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
          - instanceTypes:
            - 2vCPU-4GB
            - 4vCPU-8GB
            - 8vCPU-32GB
            publicAccess: true
            nodeCount: 3 # recommended
            autoScaling: 
              enabled: false
              minSize: 1
              maxSize: 4

          # additional node pools (for auto-scaling groups)    
          - instanceTypes:
            - 2vCPU-4GB
            publicAccess: false
          - instanceTypes:
            - 2vCPU-8GB
            publicAccess: false
          - instanceTypes:
            - 4vCPU-16GB
            publicAccess: false
            
          principal:
            type: servicePrincipal # user | role | serviceAccount | servicePrincipal | managedIdentity
            id: "arn:aws:iam::2354325499:root" # ARN (AWS) | member (GCP) | principalId (Azure)
          
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
    # NAME                    SYNCED   READY   COMPOSITION            AGE
    # xk-aws-us-east--4z74l   True     True    xkubes.skycluster.io   8h
    # xk-aws-us-west--3z59k   True     True    xkubes.skycluster.io   8h

  You can also use the SkyCluster cli commadnd:

  .. code-block:: sh

    skycluster xkube list
    # NAME                     GATEWAY                                        POD_CIDR          SERVICE_CIDR     LOCATION      EXTERNAL_NAME
    # xk-aws-us-east--4z74l    https://D51.gr7.us-east-1.eks.amazonaws.com    10.89.128.0/17    10.199.0.0/16    us-east-1a    xk-aws-us-east--4z74l-5tvkw
    # xk-aws-us-west--3z59k    https://FF2.yl4.us-west-1.eks.amazonaws.com    10.58.128.0/17    10.230.0.0/16    us-west-1b    xk-aws-us-west--3z59k-q67rq

You can easily access to the kubeconfig for your managed kubernetes cluster using the SkyCluster CLI.

.. code-block:: sh

  skycluster xkube list  # note the name and external name
  # NAME                    LOCATION      EXTERNAL_NAME
  # xk-aws-us-east--4z74l   us-east-1a    xk-aws-us-east--4z74l-5tvkw

  # For AWS EKS use the Name field
  skycluster xkube config -k xk-aws-us-east--4z74l ~/.kube/aws-config

  # For GCP GKE use the EXTERNAL_NAME field and utilize the gcloud CLI
  # use gcloud to setup kubeconfig
  # gcloud container clusters get-credentials <external-name> --location <location>
  gcloud container clusters get-credentials xk-aws-us-east--4z74l-5tvkw --location us-east-1a

  # please refer to 
  # https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl