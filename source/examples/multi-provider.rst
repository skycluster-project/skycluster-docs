Multi Provider Setup
#######################

.. toctree::
  :hidden:

  xkubemesh
  connectivity-check

**Summary:** In the examples presented here we demonstrate how to set up and manage multiple Kubernetes clusters across different cloud providers and deploy microservice applications across them.

Prerequisites
-----------------

.. In this section, we will create multiple providers and deploy managed kubernetes clusters on each of them and connect them using SkyCluster's multi-cluster management capabilities.

Before you begin make sure you have followed steps in :doc:`/getting-started/index` and ensure all  
prerequisites installed and configured, including:

- :doc:`/getting-started/providers-auth`
- :doc:`/getting-started/providers-profile`
- :doc:`/getting-started/skycluster-configs`
- :doc:`/examples/single-provider`

At this stage, you should have multiple providers created and ready for use. Check out you providers by:

.. code-block:: sh

    skycluster xprovider list
    # NAME                     PRIVATE_IP      PUBLIC_IP       CIDR_BLOCK
    # os-provider-scinet       10.16.128.11    142.w.s.185     10.16.0.0/16
    # xp-aws-us-east--vjpob    10.89.29.168    13.x.y.167      10.89.0.0/16
    # xp-aws-us-west--s0k84    10.58.3.98      13.z.w.222      10.58.0.0/16


If you have enabled the overlay setup for your local machine you should be able to reach the private IP addresses of each provider from your local machine. Try pinging the private gateway address of each provider to verify connectivity. This resembles a flat network setup created by SkyCluster. 

Check the :doc:`/getting-started/troubleshooting` page if you encounter any issues.

