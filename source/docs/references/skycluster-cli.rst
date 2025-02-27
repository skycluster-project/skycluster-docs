.. toctree::
  :hidden:

.. _SKYCLUSTERCLI: https://github.com/etesami/skycluster-cli

SkyCluster Cli
##############

Using ``skycluster-cli`` tool you can call skycluster related APIs. Please see the `SkyCluster Cli <SKYCLUSTERCLI_>`_ repository.

Installation
------------
Download the latest pre-built binary from the `releases page <SKYCLUSTERCLI_>`_ and put it in your PATH.

Configuration
-------------
Create a configuration file in your home directory named ``.skycluster``. The configuration file should look like this:

.. code-block:: yaml

    kubeconfig:
      sky-manager: /home/ubuntu/.kube/config
      sky-app: /tmp/k3s.yaml
    overlay:
      server: server_ip
      token: token
      port: 6443


Available Commands
------------------

.. code-block:: bash

    # Show help and usage message
    skycluster --help
    
    # List all gateway nodes
    skycluster skyprovider list
    skycluster skyprovider delete --all
    skycluster skyprovider delete --provider-name aws
    
    # List all skyvm instances across all providers
    skycluster skyvm list

    # List all available flavors across all providers
    skycluster skyvm flavor list
    # List all available flavors across gcp and aws provider
    skycluster skyvm flavor list --provider-name aws,gcp

    # List all available images across all providers
    skycluster skyvm image list
    # List all available images across gcp and aws provider
    skycluster skyvm image list --provider-name aws,gcp
    skycluster skyvm delete --all
    skycluster skyvm delete --provider-name aws