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
.. _GCLOUD: https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl
.. _KUBECTL: https://kubernetes.io/docs/tasks/tools

Quick jump links:

- :ref:`pre-requisites`
- :ref:`create-local-cluster`
- :ref:`install-crossplane`
- :ref:`install-skycluster`
- :ref:`skycluster-cli`


.. _pre-requisites:
Pre-requisites
================

  - A Linux x86_64 machine (at least 8vCPU and 16GB RAM) with a public IP address reachable from the internet
  - A local Kubernetes cluster installed (e.g., `kind <KIND_>`_)
  - `Kubectl <KUBECTL_>`_
  - `Helm <HELM_>`_

``SkyCluster Operator`` runs as a Kubernetes operator and requires a
Kubernetes cluster to run on. You can use any Kubernetes cluster,
including a local cluster created using `kind <KIND_>`_. In addition to the Kubernetes cluster, you need to have the `Kubectl <KUBECTL_>`_ and `Helm <HELM_>`_ installed on your machine.

SkyCluster acts as a broker between different cloud providers, and hence it requires a **public IP address** to be reachable from the internet. You can simply use your machine's public IP address if it is directly connected to the internet. If your machine is behind a NAT or firewall, you need to set up port forwarding to forward the required ports to your machine. 

If you are using a cloud VM, make sure the VM has at least 8vCPUs and 16GB of RAM to run the local cluster and SkyCluster components smoothly. Larger resources are recommended for production workloads and cloud provider environments.

You need to open the following ports on your firewall to allow communication cross-domain:

  - **4500/UDP**: Required for inter-cluster communication
  - **41641/UDP**: Required for overlay setup (tailscale)
  - **8000/TCP**: Required for SkyCluster dashboard
  - **8080/TCP**: Required for overlay setup (headscale)

  ----
  
  - **3000/TCP**: Required for Grafana dashboard (optional)
  - **9090/TCP**: Required for Prometheus monitoring (optional)
  - **6443/TCP**: Required for Kubernetes API server (optional)


If you intend to use kubectl or other local tools to interface with GKE service offered by
GCP you need to ensure ``gcloud`` is installed (`installation guide <GCLOUD_>`_).

----

.. _create-local-cluster:
Create a Local Cluster
========================
 
A local cluster is required to run the ``skycluster-operator`` and act as the point of 
contact for submitting your application. You can create a local management Kubernetes cluster using ``kind`` with the following command for testing purposes. If your machine has a public IP address you can bound the cluster to it by using the ``--advertise-address`` flag. If you plan to use the cluster for production purposes, you should consider using a more robust solution such as `kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/>`_ or `Rancher <https://rancher.com/docs/rancher/v2.5/quick-start/>`_.

.. code-block:: sh

   kind create cluster --name skycluster --config skycluster-kind.yaml


and the ``skycluster-kind.yaml`` file should contain the following content:

.. code-block:: yaml
  :linenos:

  kind: Cluster
  apiVersion: kind.x-k8s.io/v1alpha4
  networking:
    podSubnet: 10.0.0.0/19
    serviceSubnet: 10.0.32.0/19
    apiServerAddress: 0.0.0.0
    apiServerPort: 6443
  kubeadmConfigPatches:
    - |
      kind: ClusterConfiguration
      apiServer:
        certSANs:
          - 127.0.0.1
          - 0.0.0.0
          - skycluster.local
          - a.b.c.d    # Replace with your cluster internal IP
          - e.f.g.h    # Replace with your cluster public IP
  nodes:
    - role: control-plane
      extraPortMappings:
      # Required for inter-cluster communication
      - containerPort: 4500
        hostPort: 4500
        protocol: UDP
      # Required for overlay setup
      - containerPort: 30080
        hostPort: 8080
        protocol: TCP
      
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

----

.. _install-crossplane:
Install Crossplane
==================
To manage the underlying cloud resources, you need to install `Crossplane <CROSSPLANE_>`_ in your cluster. You can do this using the following command:

.. code-block:: sh

  helm repo add crossplane-stable https://charts.crossplane.io/stable
  
  helm repo update

  helm install crossplane \
    --namespace crossplane-system \
    --create-namespace crossplane-stable/crossplane \
    --version 1.20.0 

.. note::

  Ensure that Crossplane is installed successfully and all pods are running before proceeding to the next step.

  .. code-block:: sh

    kubectl get pods -n crossplane-system


----

.. _install-skycluster:
Install SkyCluster
==================

SkyCluster Main Chart
----------------------

SkyCluster Manager supports AWS, GCP and Azure as well as on-premises infrastructure powered by OpenStack.
Install the skycluster using ``helm`` chart as follows. All settings are deployed to the fixed namespac ``skycluster-system``.

.. code-block:: sh

  helm repo add skycluster https://skycluster.io/charts
  helm repo update

  helm install skycluster skycluster/skycluster 

.. note::

  The installation may take **a few minutes** to complete depending on your internet connection. You should wait till all providers listed below are installed and healthy before proceeding to the next step.

  .. code-block:: sh

    kubectl get providers.pkg

  Ensure that all pods have ``INSTALLED`` and ``HEALTHY`` states equal to ``True``.


Once you have all providers listed above all ready, you can proceed to the next step:

SkyCluster CRDs
----------------------

.. warning::

  WIP: The following charts are not yet available for installation.

  .. code-block:: sh

    helm install skycluster-crds skycluster/skycluster 

----

.. _skycluster-cli:
SkyCluster CLI
=================

Using ``skycluster`` tool you can call skycluster related APIs. SkyCluster cli is required to setup and interact with SkyCluster resources from your local machine. 

To install SkyCluster cli tool, download the latest pre-built binary from the `releases page <https://github.com/skycluster-project/skycluster-cli/releases>`_ and put it in your PATH.

.. code-block:: sh

    curl -LO https://github.com/skycluster-project/skycluster-cli/releases/download/v0.1.2/skycluster-cli-v0.1.2-alpha.1-linux-amd64.tar.gz
    tar -xvf skycluster-cli-v0.1.2-alpha.1-linux-amd64.tar.gz
    sudo mv skycluster /usr/local/bin/skycluster

Configuration
-------------
Create a configuration file in your home directory named ``.skycluster``. The configuration file should look like this:

.. code-block:: yaml

    # Write the full path to your kubeconfig file
    kubeconfig: /home/ubuntu/.kube/config

When you have installed the CLI tool and created the configuration file, you can use the ``skycluster`` command to interact with SkyCluster resources. First, launch the following command to setup the initial configuration:

.. code-block:: sh

    export PUBLIC_KEY=~/.ssh/id_rsa.pub
    export PRIVATE_KEY=~/.ssh/id_rsa
    export API_SERVER=$(curl -s ifconfig.io)

    skycluster setup \
      --apiserver ${API_SERVER}:6443 \
      --public ${PUBLIC_KEY} \
      --private ${PRIVATE_KEY}



    
Check the status of the SkyCluster operator:

.. code-block:: bash

    kubectl get xsetup.skycluster.io
    # NAME              SYNCED   READY   COMPOSITION             AGE
    # skycluster-mgmt   True     True    xsetups.skycluster.io   21h

Once ready, you can follow the examples in the SkyCluster documentation to deploy applications.


.. SkyCluster CA
.. ----------------

.. SkyCluster uses a self-signed CA to sign the certificates for its components. The CA is automatically generated during the installation of the SkyCluster operator. You need to install the CA in your cluster to enable secure communication between the SkyCluster components.

.. You can run the following command to install the CA in your cluster:

.. .. code-block:: sh

..   curl -s https://skycluster.io/configs/install-ca.sh | bash

.. The above script performs the following steps:

.. .. container:: toggle 

..   .. container:: header

..     **install-ca.sh**

..   .. code-block:: sh
..     :linenos:

..     CA_CERT=$(kubectl get secret skycluster-self-ca \
..       -n skycluster-system -o jsonpath='{.data.ca\.crt}')
    
..     # Ensure the CA_CERT is not empty then:
    
..     echo "$CA_CERT" | base64 -d | \
..       sudo tee /usr/local/share/ca-certificates/skycluster.crt > /dev/null
    
..     sudo update-ca-certificates --fresh


.. SkyCluster Secret
.. -----------------

.. You need to create a secret containing a public key and a private key for the skycluster
.. to authenticate itself with its components.
.. The secret should be created in the ``skycluster-system`` namespace.

.. First export your public and private keys, assuming **your private and public keys are named** ``id_rsa`` and ``id_rsa.pub`` or adjust the paths to your keys:

.. .. code-block:: sh

..   export PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
..   export PRIVATE_KEY=$(cat ~/.ssh/id_rsa | base64 -w0)

..   # the kind cluster kubeconfig
..   export KUBECONFIG_B64=$(kubectl config view --minify --flatten --context=kind-skycluster | base64 -w0)

.. And then run the following command to generate the secret:

.. .. code-block:: sh

..   curl -s https://skycluster.io/configs/skysecret-cfg.sh | bash

.. **Alternatively**, you can create a secret using a YAML file below:

.. .. container:: toggle 

..   .. container:: header 

..     **skysecret-example.yaml**

..   .. code-block:: yaml
..     :linenos:

..     apiVersion: v1
..     kind: Secret
..     metadata:
..       namespace: skycluster-system
..       name: public-private-key
..       labels:
..         skycluster.io/managed-by: skycluster
..         skycluster.io/secret-type: default-keypair
..     type: Opaque
..     stringData:
..       config: |
..         {
..           "publicKey": "ssh-rsa AAAAB3NzaC1yc...fKEgCExt6YjE= ubuntu@cluster-dev1",
..           "privateKey": "LS0tLS1CRUdJTiBPUEVOU1..gS0VZLS0tLS0K"
..         }
..     ---
..     apiVersion: v1
..     kind: Secret
..     metadata:
..       namespace: skycluster-system
..       name: k8s-skycluster-management
..       labels:
..         skycluster.io/managed-by: skycluster
..         skycluster.io/secret-type: k8s-connection-data
..         skycluster.io/cluster-name: skycluster-management
..     type: Opaque
..     data:
..       kubeconfig: YXBpVmVyc2lvbjo...


.. ----

.. **Providers' Configuration**:

.. Once all providers are installed, you need to provide form of authentication
.. to enable using hyperscalers such as AWS and GCP. 
.. Please follow the instructions 
.. in `provider configuration <providers-configs.html>`_ page to apply required 
.. configurations.

.. ----

.. **Setting up Regions and Locations**:

.. To enable ``skycluster-manager`` to deploy services across different 
.. providers you need to setup each regions within each prvoider 
.. that you configured in the previouse step.

