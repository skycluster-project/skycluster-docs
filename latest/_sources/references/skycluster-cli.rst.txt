SkyCluster CLI
************************

.. toctree::
  :hidden:



Using ``skycluster`` tool you can call skycluster related APIs. For issues and requested features please check out the `SkyCluster Cli <https://github.com/skycluster-project/skycluster-cli>`_ repository.

Installation
------------
Download the latest pre-built binary from the `releases page <https://github.com/skycluster-project/skycluster-cli/releases>`_ and put it in your PATH.

Configuration
-------------
Create a configuration file in your home directory named ``.skycluster``. The configuration file should look like this:

.. code-block:: yaml

    kubeconfig: /home/ubuntu/.kube/config
    namespace: skycluster-system

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

    # Print the kubeconfig of a specific xkube
    skycluster xkube config -k <xkube-name>
