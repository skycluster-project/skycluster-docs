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

    # Show help and usage message
    skycluster --help
    
Available Commands
------------------

``profile``
^^^^^^^^^^^^^^

.. code-block:: bash

    # List all provider profiles
    skycluster profile list
    skycluster profile create -f <provider-config-file>.yaml -n <provider-name>
    skycluster profile delete -n <provider-name>

``xprovider``
^^^^^^^^^^^^^^

.. code-block:: bash

    # List all gateway nodes
    skycluster xprovider list
    skycluster xprovider create -f <provider-config-file>.yaml -n <provider-name>
    skycluster xprovider delete -n <provider-name>


``xprovider ssh``
^^^^^^^^^^^^^^^^^

.. code-block:: bash
    
    # Enable ssh for selected provider(s)
    skycluster xprovider ssh --enable
    skycluster xprovider ssh --disable
    
    # Enable ssh for a specific provider
    skycluster xprovider ssh -n <provider-name> --enable


``xinstance``
^^^^^^^^^^^^^^

.. code-block:: bash

    # List all xinstance instances across all providers
    skycluster xinstance list
    skycluster xinstance create -f <instance-config-file>.yaml -n <instance-name>
    skycluster xinstance delete -n <instance-name>

``xkube``
^^^^^^^^^^^^^^

.. code-block:: bash

    # List all xkube instances across all providers
    skycluster xkube list
    skycluster xkube create -f <xkube-config-file>.yaml -n <xkube-name>
    skycluster xkube delete -n <xkube-name>


``xkube config``
^^^^^^^^^^^^^^^^

.. code-block:: bash

    # Write kubeconfig file for all xkubes
    skycluster xkube config -o <output-file>.kubeconfig
    
    # Write kubeconfig file for a specific xkube
    skycluster xkube config -k <xkube-name> -o <output-file>.kubeconfig

``xkube mesh``
^^^^^^^^^^^^^^^^

.. code-block:: bash

    # Enable inter-cluster connectivity between all existing Kubernetes clusters
    skycluster xkube mesh --enable
    skycluster xkube mesh --disable

``cleanup``
^^^^^^^^^^^^^^^^

.. code-block:: bash

    # Cleanup overlay and service mesh configurations
    skycluster cleanup    
    