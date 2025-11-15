Providers Authentication 
################################

.. toctree::
  :hidden:

Before deploying resources to cloud providers, you need to configure authentication for each provider.
SkyCluster supports multiple cloud providers, including AWS, GCP, Azure, and OpenStack and on-premises edge clusters.
This guide provides step-by-step instructions to set up authentication for each supported provider.
All configurations are stored in the fixed ``skycluster-system`` namespace.

Quick jump links:

- :ref:`aws-cloud`
- :ref:`gcp-cloud`
- :ref:`azure-cloud`
- :ref:`openstack`
- :ref:`on-premises-edge`

.. _aws-cloud:
AWS Cloud
=================

In the AWS Console, navigate to Identity and Access Management (IAM) 
and create a new user. Ensure the user has the following 
permission policy: ``AmazonEC2FullAceess``. 
Next, in the Security Credentials section, generate an access key. 
After obtaining the ``Access Key ID`` and ``Secret Access Key``, export them as
environmental variables and run the configuration script:


.. code-block:: sh

  export AWS_ACCESS_KEY_ID=abcd....xwyz # replace with your ID
  export AWS_SECRET_ACCESS_KEY=abcd....xwyz # replace with your Key

Then execute the command below to configure the AWS provider:

.. code-block:: sh

  curl -s https://skycluster.io/configs/aws-cfg.sh | bash


.. _gcp-cloud:
GCP Cloud
=================

Create a new project in Google Cloud and enable the following APIs:

- ``Cloud Billing API`` 
- ``Kubernetes Engine API``
- ``Compute Engine API``

Make sure to add a service account and generate a service account key file in JSON format and download the file.
Then:

.. code-block:: sh

  # Use absolute path to the service account key file
  export GCP_SVC_ACC_PATH=/home/ubuntu/my-gcp-svc-acc.json
  export PROJECT_ID=my-gcp-project-id

Then execute the command below to configure the GCP provider:

.. code-block:: sh

  curl -s https://skycluster.io/configs/gcp-cfg.sh | bash


.. _azure-cloud:
Azure Cloud
===================

Create a subscription and note your Subscription ID. 
Next you will need to create a service principal and authentication file.
The easiest way to do this is through the ``CloudShell`` in the Azure portal.
**Open the Azure portal and then run the following command in the CloudShell** 
to create the service principal:

.. code-block:: sh

  export SUBS_ID=<subsc-id>
  az ad sp create-for-rbac --name skycluster-setup  \
    --role Owner --sdk-auth \
    --scopes /subscriptions/${SUBS_ID} > azure_config.json
  
Download the ``azure_config.json`` file and export the path as an environmental variable:

.. code-block:: sh

  export AZURE_CONFIG_PATH=/home/ubuntu/azure_config.json

Then execute the command below to configure the Azure provider:

.. code-block:: sh

  curl -s https://skycluster.io/configs/azure-cfg.sh | bash


.. _openstack:
Openstack 
========================

If you have on-premises infrastructure managed by Openstack you can follow the steps below:

.. code-block:: sh

  export AUTH_URL="url"
  export USERNAME="username"
  export PASSWORD="pass"
  export TENANT_NAME="project-name"
  export REGION="region"
  export USER_DOMAIN_NAME="Default"
  export PROJECT_DOMAIN_NAME="Default"

Then execute the command below to configure your Openstack provider:

.. code-block:: sh

  curl -s https://skycluster.io/configs/openstack-cfg.sh | bash

    
Repeat the steps for each additional openstack provider you want to configure.

SAVI Testbed (OpenStack Example)
--------------------------------

We offer computing resources for academic research through the SAVI Testbed, 
a distributed computing infrastructure built on the OpenStack framework.
To request access, please contact us. Once granted access, 
use your ``USERNAME`` and ``PASSWORD`` and
follow the steps below to configure the SAVI Testbed provider.
You can choose from the following available regions: ``SCINET``, ``VAUGHAN``, ``BAHEN``.

.. code-block:: sh

  export AUTH_URL="http://iamv3.savitestbed.ca:5000/v3"
  export USERNAME="USERNAME"
  export PASSWORD="PASSWORD"
  export TENANT_NAME="skycluster"
  export REGION="SCINET|VAUGHAN|BAHEN"
  export USER_DOMAIN_NAME="Default"
  export PROJECT_DOMAIN_NAME="Default"

Then execute the command below to configure the provider:

.. code-block:: sh

  curl -s https://skycluster.io/configs/openstack-cfg.sh | bash

Repeat the steps for each additional regions you want to configure.


.. _on-premises-edge:
On-premises Edge Clusters
===========================

SkyCluster supports on-premises edge clusters, where a group of edge devices can be registered as an edge provider to run workloads. This enables orchestration of workloads across the devices.

A gateway device with a static IP address and specific internet-accessible ports is required. The gateway provides access to the edge devices and their internal IP addresses. SkyCluster uses SSH connections to configure both the gateway and worker nodes, installing K3S with the gateway serving as the controller and the edge devices functioning as worker nodes. This setup allows the edge cluster to operate independently while collaborating with other clusters to share application workloads.

Before setting up an edge cluster, ensure the following requirements are met:

- The gateway device has a static IP address.
- Port 443 on the gateway is accessible from the internet.
- SSH access is enabled on the gateway and all worker nodes.
- A private key is configured for SSH access on the gateway and all edge devices.


Private Key Secret 
---------------------

A secret containing the private SSH key must be created to allow SkyCluster to connect to the gateway and worker nodes. Make sure the SSH key has access to both the gateway and worker nodes. 
Then export your encoded private key and the desired secret name as environment variables:

.. code-block:: sh

  export PRIVATE_KEY=$(cat ~/.ssh/id_rsa | base64 -w0)
  export SECRET_NAME=savi-toronto-edge-ssh-key
  # replace with your desired secret name, e.g., savi-toronto-edge-ssh-key
  # the secret name will be referenced when you setup gateway node.

And then run the following command to generate the secret:

.. code-block:: sh

  curl -s https://skycluster.io/configs/secret-cfg.sh | bash
