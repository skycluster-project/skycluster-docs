SkyCluster 
##########

.. image:: _static/imgs/skycluster-logo-v1.png
  :scale: 15%
  :alt: SkyCluster Logo
  :align: center




What is SkyCluster?
*******************

``SkyCluster`` is a research project focused on studying 
the deployment of containerized applications in multi-cloud and 
hybrid-cloud environments. 
The project's goal is to simplify the deployment process by 
offering same interfaces as Kubernetes, but with enhanced 
capabilities to deploy applications across various hybrid 
and multi-cloud providers. 
By doing so, it aims to reduce deployment costs while meeting 
the application's performance and compliance requirements.


To this end, we introduce the ``skycluster-manager`` 
as a custom Kubernetes controller designed to 
facilitate the deployment of Kubernetes resources 
in a multi-cloud or hybrid-cloud Kubernetes 
environment, specifically tailored for a given application.

The ``skycluster-manager`` operates within a management Kubernetes cluster. Users interact with this management cluster by submitting their application manifests, which include deployments, services, and config maps. The ``skycluster-manager`` then provisions a new multi-cloud or hybrid-cloud Kubernetes cluster and deploys the submitted application manifests into it.

Read the ``SkyCluster`` documentation to learn more about the project and how to use it.

.. toctree::
  :maxdepth: 3
  :includehidden:

  docs/user-guide/index
  docs/use-cases/index
  docs/references/index

  
.. 
  This are the main sections such as
  installation, configurations, about, 
