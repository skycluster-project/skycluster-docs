SkyCluster Configuration
************************

.. toctree::
  :hidden:

SkyCluster Secret
=================

You need to create a secret containing a public key and a private key for the skycluster
to authenticate itself with its components.
The secret should be created in the same namespace as the skycluster. 

.. container:: toggle open

  .. container:: header open

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