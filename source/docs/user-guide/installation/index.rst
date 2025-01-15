Installation
############

.. toctree::
  :maxdepth: 3
  :caption: Getting Started
  :hidden:
  
  providers-configs
  skycluster-configs


**Pre-requisites**:

``SkyCluster Manager`` depends on the following tools:

- `kubectl <https://kubernetes.io/docs/tasks/tools/install-kubectl/>`_
- `helm <https://helm.sh>`_
- `kind <https://kind.sigs.k8s.io>`_
- `Crossplane <https://crossplane.io/>`_

We utilize `kind <https://kind.sigs.k8s.io>`_ to create a local cluster to install and test SkyCluster Manager.


**Create a Local Management Kubernetes Cluster**: 
 
A management Kubernetes cluster is
required to run the ``skycluster-manager`` and act as the point of 
contact for submitting your application. You can create a local 
management Kubernetes cluster using ``kind`` with the following command:

.. code-block:: sh

   kind create cluster --name skycluster


**Install Crossplane**: 

The ``skycluster-manager`` relies on 
`Crossplane <https://github.com/crossplane/crossplane>`_
for managing external cloud resources.
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


SkyCluster Manager supports AWS, GCP and Azure as well as on-premises infrastructure powered by OpenStack.
You can install all the providers or only the ones you need. To install all recommended providers, first 
ensure the CrossPlane is installed and is running: ``k get pods -ncrossplane-system | grep crossplane``, 
then run the following commands:

.. code-block:: sh

   cd skycluster-manager
   sudo kubectl apply -f ./config/installation/setup-providers.yaml

.. container:: toggle

  .. container:: header

   **setup-providers.yaml**

  .. code-block:: yaml
   
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-aws-ec2
   spec:
     package: xpkg.upbound.io/upbound/provider-aws-ec2:v1.19.0
   ---
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-gcp-compute
   spec:
     package: xpkg.upbound.io/upbound/provider-gcp-compute:v1.11.2
   ---
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-azure-compute
   spec:
     package: xpkg.upbound.io/upbound/provider-azure-compute:v1.11.0
   ---
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-azure-network
   spec:
     package: xpkg.upbound.io/upbound/provider-azure-network:v1.11.0
   ---
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-openstack
   spec:
     package: xpkg.upbound.io/crossplane-contrib/provider-openstack:v0.4.0
   ---


Additionally, there are certain packages that are required for the SkyCluster Manager internal operations. 
Install them by running the following command:

.. code-block:: sh

   cd skycluster-manager
   sudo kubectl apply -f ./config/installation/setup-dependencies.yaml

.. container:: toggle

  .. container:: header

   **setup-dependencies.yaml**

  .. code-block:: yaml

   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-ssh
   spec:
     package: docker.io/etesami/provider-ssh:latest
   ---
   apiVersion: pkg.crossplane.io/v1beta1
   kind: Function
   metadata:
     name: function-go-templating
   spec:
     package: xpkg.upbound.io/crossplane-contrib/function-go-templating:v0.9.0
   ---
   apiVersion: pkg.crossplane.io/v1beta1
   kind: Function
   metadata:
     name: function-extra-resources
   spec:
     package: xpkg.upbound.io/crossplane-contrib/function-extra-resources:v0.0.3
   ---
   apiVersion: pkg.crossplane.io/v1beta1
   kind: Function
   metadata:
     name: function-auto-ready
   spec: 
     package: xpkg.upbound.io/crossplane-contrib/function-auto-ready:v0.4.0
   ---
   apiVersion: pkg.crossplane.io/v1beta1
   kind: Function
   metadata:
     name: function-patch-and-transform
   spec:
     package: xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.8.0
   ---
   apiVersion: pkg.crossplane.io/v1
   kind: Provider
   metadata:
     name: provider-kubernetes
   spec:
     package: xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.15.1
     runtimeConfigRef:
       apiVersion: pkg.crossplane.io/v1beta1
       kind: DeploymentRuntimeConfig
       name: provider-kubernetes
   ---
   apiVersion: pkg.crossplane.io/v1beta1
   kind: DeploymentRuntimeConfig
   metadata:
     name: provider-kubernetes
   spec:
     serviceAccountTemplate:
       metadata:
         name: provider-kubernetes
   ---

Depending your internet connection this step may take a little while to complete. 
Check the status of the providers by running ``kubectl get providers``. 
Once you see the fields ``Installed=True`` and ``Status=False`` 
you can proceed to the next step. The providers' health status can take a few minutes
to update to ``True``.

**Providers' Configuration**:

Once all providers are installed, you need to provide form of authentication
to enable using hyperscalers such as AWS and GCP. 
Please follow the instructions 
in `provider configuration <providers-configs.html>`_ page to apply required 
configurations.



**Install skycluster-manager**:

.. code-block:: sh

   # download the latest release as a package


**Setting up Regions and Locations**:

To enable ``skycluster-manager`` to deploy services across different 
providers you need to setup each regions within each prvoider 
that you configured in the previouse step.

