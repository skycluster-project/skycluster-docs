Getting Started
###############

.. meta::
  :description: SkyCluster getting started guide.


The ``skycluster-manager`` operates within a management Kubernetes cluster. Users interact with this management cluster by submitting their application manifests, which include deployments, services, and config maps. The ``skycluster-manager`` then provisions a new multi-cloud or hybrid-cloud Kubernetes cluster and deploys the submitted application manifests into it.

Read the ``SkyCluster`` documentation to learn more about the project and how to use it.

.. warning::

  This is a Work In Progress (WIP). The documentation is not complete yet and the code base changes frequently.

.. toctree::
  :maxdepth: 2
  :includehidden:

  user-guide/installation/index
  user-guide/quick-start/index
  use-cases/index
  references/index

  