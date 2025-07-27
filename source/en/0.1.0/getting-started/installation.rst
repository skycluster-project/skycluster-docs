Installation
############

.. toctree::
  :hidden:
  

.. _CROSSPLANE: https://crossplane.io
.. _HELM: https://helm.sh/docs/intro/install
.. _KIND: https://kind.sigs.k8s.io/docs/user/quick-start
.. _TAILSCALE: https://tailscale.com/kb/1347/installation
.. _DOCKER_POST_INSTALL: https://docs.docker.com/engine/install/linux-postinstall
.. _DOCKER: https://docs.docker.com/get-docker

Pre-requisites
================

``SkyCluster Operator`` runs as a Kubernetes operator and requires a
Kubernetes cluster to run on. You can use any Kubernetes cluster,
including a local cluster created using `kind <KIND_>`_. 

To install and run ``SkyCluster Operator``, you need to ensure the following requirements are met on your machine:

- `Kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_
- `Helm <HELM_>`_
- `Kind <KIND_>`_
- `Docker <DOCKER_>`_ (for local cluster)
- `Crossplane <CROSSPLANE_>`_ (for managing underlying cloud resources)
- Public IP Address: The cluster in your local machine is used to act as a broker between other gateways across different cloud providers, and hence it requires a public IP address to be reachable from the internet.
.. - `CrossPlane <CROSSPLANE_>`_
.. - `Tailscale <TAILSCALE_>`_



Please make sure you have installed all tools before proceeding.
We utilize ``kind`` to create a local cluster to run SkyCluster operator.
Please ensure you can use ``kubectl`` without sudo before proceeding (refer to the 
`docker post-installation guide <DOCKER_POST_INSTALL_>`_).


Create a Local Cluster
========================
 
A local cluster is required to run the ``skycluster-operator`` and act as the point of 
contact for submitting your application. You can create a local management Kubernetes cluster using ``kind`` with the following command for testing purposes. If your machine has a public IP address you can bound the cluster to it by using the ``--advertise-address`` flag. If you plan to use the cluster for production purposes, you should consider using a more robust solution such as `kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>`_ or `Rancher <https://rancher.com/docs/rancher/v2.5/en/quick-start/>`_.

.. code-block:: sh

   kind create cluster --name skycluster --config skycluster-kind.yaml


and the ``skycluster-kind.yaml`` file should contain the following content:

.. code-block:: yaml
  :linenos:

  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  networking:
    apiServerAddress: "0.0.0.0" 
    apiServerPort: 6443 
  kubeadmConfigPatches:
    - |
      kind: ClusterConfiguration
      apiServer:
        certSANs:
          - "127.0.0.1"
          - "skycluster.local"
          - "X.X.X.X"  # Replace with your cluster internal IP
          - "X.X.X.X"  # Replace with your cluster public IP
  nodes:
    - role: control-plane
      
The cluster is used used to act as a broker between other gateways across different cloud providers, and hence it requires a public IP address to be reachable from the internet. Once installed replace the `0.0.0.0` with the actual public IP address of your machine in the `~/.kube/config` file:

.. code-block:: sh

  sed -i "s/0\.0\.0\.0/$(curl -s ifconfig.io)/g" ~/.kube/config

At least one node in your cluster should be labeled as a gateway node. You can label the control plane node as follows:

.. code-block:: sh

  kubectl label node skycluster-control-plane \
    skycluster.io/node-type=gateway \
    submariner.io/gateway=true

.. warning::
  Ensure that a node is labeled as a gateway node and that you can access the cluster using the public IP address before proceeding to the next step.

Install Crossplane
==================
To manage the underlying cloud resources, you need to install `Crossplane <CROSSPLANE_>`_ in your cluster. You can do this using the following command:

.. code-block:: sh

  helm install crossplane \
    --namespace crossplane-system \
    --create-namespace crossplane-stable/crossplane \
    --version 1.20.0 

  # Ensure that Crossplane is installed successfully
  # and all pods are running
  kubectl get pods -n crossplane-system


Install SkyCluster
==================

SkyCluster Manager supports AWS, GCP and Azure as well as on-premises infrastructure powered by OpenStack.
Install the skycluster using ``helm``:

.. code-block:: sh

  helm repo add skycluster https://skycluster.io/charts
  helm repo update

  helm install skycluster skycluster/skycluster \
    --namespace skycluster --create-namespace

.. note::

  The installation may take **a few minutes** to complete depending on your internet connection. You should wait till all providers listed below are installed and healthy before proceeding to the next step.

  .. code-block:: sh

    kubectl get providers

  Ensure that all pods are in the ``Running`` state before proceeding to the next step.

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

