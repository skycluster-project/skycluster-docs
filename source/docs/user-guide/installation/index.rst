Installation
############

.. toctree::
  :maxdepth: 3
  :caption: Getting Started
  :hidden:
  
  providers
  skycluster-configs


**Install skycluster-manager**:

.. code-block:: console

   # download the latest release as a package


**Install Management Kubernetes Cluster**: 
 
A management Kubernetes cluster is
required to run the ``skycluster-manager`` and act as the point of 
contact for submitting your application. You can create a local 
management Kubernetes cluster using ``kind`` with the following command:

.. code-block:: bash

   kind create cluster

**Install Crossplane**: 

The ``skycluster-manager`` relies on 
`Crossplane <https://github.com/crossplane/crossplane>`_
for managing external cloud resources.
Crossplane is a Kubernetes extension that allows 
Kubernetes to manage external cloud resources via standard Kubernetes 
APIs. To install Crossplane, use the following commands:

.. code-block:: bash

   helm repo add crossplane-stable https://charts.crossplane.io/stable
   helm repo update

   helm install crossplane \
      --namespace crossplane-system \
      --create-namespace crossplane-stable/crossplane \
      --version 1.16.0


Once Crossplane is installed, follow the instructions 
`here <providers.html>`_ to install all the required 
providers, or simply run the following command:

.. code-block:: bash

   cd skycluster-manager
   sudo kubectl apply -f ./config/installation/crossplane-setup.yaml


**Providers Authentication Configuration**:

Cloud or hybrid providers require authentication to be used by the 
``skycluster-manager``. You will need to create a user with sufficient 
permissions and provide the necessary access credentials. Follow the 
instructions `here <./docs/crossplane-config.md>`_ 
to configure authentication for ``AWS``, ``GCP``, and ``Azure``.

### Setting up Regions and Locations
To enable ``skycluster-manager`` to deploy services across different 
providers you need to setup each regions within each prvoider 
that you configured in the previouse step.

