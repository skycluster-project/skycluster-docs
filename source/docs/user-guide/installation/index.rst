Installation
############

.. toctree::
  :hidden:
  
  providers-configs
  skycluster-configs
  overlay-server-config

.. _CROSSPLANE: https://crossplane.io
.. _HELM: https://helm.sh/docs/intro/install
.. _KIND: https://kind.sigs.k8s.io/docs/user/quick-start
.. _TAILSCALE: https://tailscale.com/kb/1347/installation
.. _DOCKER_POST_INSTALL: https://docs.docker.com/engine/install/linux-postinstall

**Pre-requisites**:

``SkyCluster Manager`` depends on the following tools:

- `Kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_
- `Helm <HELM_>`_
- `Kind <KIND_>`_
- `CrossPlane <CROSSPLANE_>`_
- `Tailscale <TAILSCALE_>`_

Please make sure you have installed all tools before proceeding.
We utilize ``kind`` to create a local cluster to install and test SkyCluster Manager.
Please ensure you can use ``kubectl`` without sudo before proceeding (refer to the 
`docker post-installation guide <DOCKER_POST_INSTALL_>`_).



**Create a Local Management Kubernetes Cluster**: 
 
A management Kubernetes cluster is
required to run the ``skycluster-manager`` and act as the point of 
contact for submitting your application. You can create a local 
management Kubernetes cluster using ``kind`` with the following command:

.. code-block:: sh

   kind create cluster --name skycluster


**Install Crossplane**: 

The ``skycluster-manager`` relies on 
Crossplane for managing external cloud resources.
Crossplane is a Kubernetes extension that allows 
Kubernetes to manage external cloud resources via standard Kubernetes 
APIs. To install Crossplane, use the following commands:

.. code-block:: sh

   helm repo add crossplane-stable https://charts.crossplane.io/stable
   helm repo update

   helm install crossplane \
      --namespace crossplane-system \
      --create-namespace crossplane-stable/crossplane \
      --version 1.18.0

You need to ensure the CrossPlane is installed and is running: ``k get pods -ncrossplane-system | grep crossplane`` before proceeding to the next step. 

**Install SkyCluster**: 

SkyCluster Manager supports AWS, GCP and Azure as well as on-premises infrastructure powered by OpenStack.
You can install all the providers or only the ones you need. Create a settings file 
``settings.yaml`` with the following content and set ``enabled`` to ``false`` for the providers you don't want to be installed:

.. code-block:: yaml
  :linenos:

  providers:
    public:
      aws: 
        enabled: true
      gcp: 
        enabled: true
      azure: 
        enabled: true
      azure-network: 
        enabled: true
    private:  
      openstack: 
        enabled: true

Then run the following command to install the skycluster using ``helm``:

.. code-block:: sh

  helm repo add skycluster https://skycluster.io/charts
  helm repo update

  helm install skycluster skycluster/skycluster \
    --set install=true -f settings.yaml

.. warning::

  This step may take few mintues to be completed depending on your internet connection.
  You need to wait for all the providers to become available and healthy before proceeding to the next step.
  Check the status of the providers by running ``kubectl get providers``. 
  and wait till you see the fields ``Installed=True`` and ``HEALTHY=True`` for all the providers. 

**Providers' Configuration**:

Once all providers are installed, you need to provide form of authentication
to enable using hyperscalers such as AWS and GCP. 
Please follow the instructions 
in `provider configuration <providers-configs.html>`_ page to apply required 
configurations.


**Setting up Regions and Locations**:

To enable ``skycluster-manager`` to deploy services across different 
providers you need to setup each regions within each prvoider 
that you configured in the previouse step.

