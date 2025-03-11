.. toctree::
  :hidden:

Configurations
##############

SkyCluster Annotations
======================

Global Annotations
------------------

.. container:: toggle open

  .. code-block:: yaml
    :linenos:
    :emphasize-lines: 1,5,10,27

    skycluster.io/managed-by: skycluster
    
    # You can pause the reconciliation of the object and its 
    # offspring objects by setting this annotation to "true"
    skycluster.io/pause: "true"

    # Often there is a need to use existing external managed resources
    # such as a public network, an existing router, etc.
    # You can specify the external resource ID using the following labels
    # skycluster.io/ext-Kind-Group-Version: <resource-name>
    # Due to the annotation key length limit, we only use the first word
    # of the api group. Please check examples below:

    # Azure:
    # For Azure, we may specify the resource group by:
    # this prevents creating, modifying or deleting the resource group
    # by SkyCluster. However, SkyCluster pull resource group information 
    # and use them when creating other resources.
    skycluster.io/ext-ResourceGroup-azure-v1beta1: skycluster-manual

    # OpenStack:
    # For OpenStack providers, SkyCluster does not support 
    # creating a public (external) network.
    # The network should exist before creating the provider, 
    # hence you always need to specify the external subnet
    # if you need to allocate an external (floating) IP.
    skycluster.io/ext-os-public-subnet-name: ext-net
    # Other examples to specify other resources (openstack):
    # Specify a project (tennat)
    skycluster.io/ext-ProjectV3-identity-v1alpha1: <tenant-id>
    # Specify a network
    skycluster.io/ext-NetworkV2-networking-v1alpha1: <network-id>
    # Specify a subnet
    skycluster.io/ext-SubnetV2-networking-v1alpha1: <subnet-id>
    # Specify a router
    skycluster.io/ext-RouterV2-networking-v1alpha1: <router-id>    
