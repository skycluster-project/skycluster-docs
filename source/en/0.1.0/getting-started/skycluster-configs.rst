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

Join SkyCluster Overlay
========================

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

To maintain the connection to the overlay network, you can run the above script periodically or set it up a cron job to run it at regular intervals. This will ensure that your machine remains connected to the SkyCluster overlay network. To add the script to a cron job, you can use the following command:

.. code-block:: sh
  
  mkdir -p ~/.skycluster

  # download the cron script
  curl -fsSL https://skycluster.io/configs/tailscale-cron.sh -o ~/.skycluster/tailscale-cron.sh
  chmod +x ~/.skycluster/tailscale-cron.sh

  # backup existing cron jobs
  sudo crontab -u root -l 2>/dev/null > /tmp/mycron || true

  # add the cron job to run the script every 5 minutes
  echo "*/5 * * * * ~/.skycluster/tailscale-cron.sh" >> /tmp/mycron
  sudo crontab -u root /tmp/mycron


.. warning::

  This step is required to connect your machine to the SkyCluster overlay network. If you do not run this step, the SkyCluster operator will not be able to manage the resources within other providers. You will not be able to access the resources within the SkyCluster overlay network from your machine.

----
