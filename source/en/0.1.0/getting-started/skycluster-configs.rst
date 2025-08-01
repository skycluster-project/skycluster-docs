SkyCluster Configuration
************************

.. toctree::
  :hidden:


SkyCluster Setup
=================

Create an object of type ``XSetup`` to configure the SkyCluster operator. This object is used to configure the SkyCluster operator and its components, including the provider configs objects for ``provider-helm`` and ``provider-kubernetes`` operator. Make sure the labels are set correctly to ensure the operator can manage the resources.

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XSetup
    metadata:
      name: mycluster
      labels:
        skycluster.io/managed-by: skycluster
    spec: 
      # The public IP of the api server running SkyCluster controller
      apiServer: A.B.C.D:6443
      # If set to true, the SkyCluster operator will deploy submariner 
      # to enable cross-cluster communication
      submariner:
        enabled: true

    
Check the status of the SkyCluster operator:

.. code-block:: bash

    kubectl get xsetup.skycluster.io mycluster

Once ready, you can follow the examples in the SkyCluster documentation to deploy applications.

----

SkyCluster Overlay
=================

SkyCluster uses an overlay network to enable communication between private networks across different 
providers. The overlay network is created using open source ``tailscale`` for client and ``headscale`` as the server, which provides a secure mesh network. The headscale server is deployed in the SkyCluster namespace and is responsible for managing the overlay network. SkyCluster automatically configures the headscale server and the tailscale clients within each provider. However to enabled access to the overlay network from this machine, you need to install the ``tailscale`` client and authenticate it with the headscale server.

First install the ``tailscale`` client on your machine:

.. code-block:: sh

  curl -fsSL https://tailscale.com/install.sh | sh

Then authenticate the client with the headscale server you can run the following script. This script will retrieve the headscale server connection data from SkyCluster and authenticate your system with it:

.. code-block:: sh

  curl -s https://skycluster.io/configs/tailscale-connect.sh | bash


The above script performs the following steps:

.. container:: toggle 

  .. container:: header

    **tailscale-connect.sh**

  .. code-block:: sh
    :linenos:

    HEADSCALE_DATA=$(kubectl get secret headscale-connection-secret \
      -n skycluster-system -o jsonpath='{.data}')

    if [[ -z "$HEADSCALE_DATA" ]]; then
      echo "Error: Headscale data not found in headscale-connection-secret secret" >&2
      exit 1
    fi

    # KEY
    HEADSCALE_KEY=$(echo "$HEADSCALE_DATA" | jq -r '."preauth.json"' | base64 -d | jq -r '.key')
    if [[ -z "$HEADSCALE_KEY" ]]; then
      echo "Error: Headscale key not found in headscale-connection-secret secret" >&2
      exit 1
    fi

    # TAILSCALE Address
    SERVER="https://$(curl -s ifconfig.io):8080"
    sudo tailscale up --login-server $SERVER --auth-key $HEADSCALE_KEY --accept-routes

----

SkyCluster Secret
=================

You need to create a secret containing a public key and a private key for the skycluster
to authenticate itself with its components.
The secret should be created in the ``skycluster`` namespace.

First export your public and private keys, assuming **your private and public keys are named** ``id_rsa`` and ``id_rsa.pub`` or adjust the paths to your keys:

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
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/secret-type: keypair
    type: Opaque
    stringData:
      config: |
        {
          "publicKey": "ssh-rsa AAAAB3NzaC1yc...fKEgCExt6YjE= ubuntu@cluster-dev1",
          "privateKey": "LS0tLS1CRUdJTiBPUEVOU1..gS0VZLS0tLS0K"
        }
