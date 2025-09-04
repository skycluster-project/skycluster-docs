SkyCluster CLI
************************

.. toctree::
  :hidden:



Using ``skycluster-cli`` tool you can call skycluster related APIs. For issues and requested features please check out the `SkyCluster Cli <https://github.com/skycluster-project/skycluster-cli>`_ repository.

Installation
------------
Download the latest pre-built binary from the `releases page <https://github.com/skycluster-project/skycluster-cli/releases>`_ and put it in your PATH.

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
    skycluster xprovider list
    skycluster xprovider delete --all
    skycluster xprovider delete --platform aws
    
    # List all xinstance instances across all providers
    skycluster xinstance list
    skycluster xinstance delete --all
    skycluster xinstance delete --platform aws

    # List all xkube instances across all providers
    skycluster xkube list
    skycluster xkube delete --all
    skycluster xkube delete --platform aws



    # List all available flavors across all providers
    skycluster xinstance flavor list
    # List all available flavors across gcp and aws provider
    skycluster xinstance flavor list --platform aws,gcp

    # List all available images across all providers
    skycluster xinstance image list
    # List all available images across gcp and aws provider
    skycluster xinstance image list --platform aws,gcp

    # Print the overlay k8s kubeconfig
    skycluster skyk8s config show