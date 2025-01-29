SkyCluster Configuration
************************

.. toctree::
  :hidden:

SkyCluster Secret
=================

You need to create a secret containing a public key and a private key for the skycluster
to authenticate itself with its components.
The secret should be created in the ``skycluster`` namespace.

First export your public and private keys (adjust the paths to your keys):

.. code-block:: sh

  export PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
  export PRIVATE_KEY=$(cat ~/.ssh/id_rsa | base64 -w0)

And then run the following command to generate the secret:

.. code-block:: sh

  curl -s https://skycluster.io/configs/skysecret-cfg.sh | bash

**Alternatively**, you can create a secret using a YAML file below:

.. container:: toggle 

  .. container:: header 

    **skysecret-example.yaml**

  .. code-block:: yaml
    :linenos:

    apiVersion: v1
    kind: Secret
    metadata:
      namespace: skycluster
      name: public-private-key
    type: Opaque
    stringData:
      config: |
        {
          "public_key": "ssh-rsa AAAAB3NzaC1yc...fKEgCExt6YjE= ubuntu@cluster-dev1",
          "privateKey": "LS0tLS1CRUdJTiBPUEVOU1..gS0VZLS0tLS0K",
        }