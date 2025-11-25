SkyCluster Configuration
************************

.. toctree::
  :hidden:


Join SkyCluster Overlay (optional)
===============================================

SkyCluster uses an overlay network to enable communication between private networks across different 
providers. The overlay network is created using open source ``tailscale`` for client and ``headscale`` as the server. The headscale server is deployed in the SkyCluster namespace and is responsible for managing the overlay network. SkyCluster automatically configures the headscale server and the tailscale clients within each provider. However to enabled access to the overlay network from your local machine, you need to install the ``tailscale`` client and authenticate it with the headscale server.

.. note::

  This step is optional but recommended to enable access to the resources within the local machine outside of the SkyCluster control plane. 

To connect your local machine to the overlay network, first install the ``tailscale`` client on your machine:

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

Automating Connectivity
-----------------------

To maintain the connection to the overlay network, you can run the above script periodically or set it up a cron job to run it at regular intervals. This will ensure that your machine remains connected to the SkyCluster overlay network. To add the script to a cron job, you can use the following command:

.. code-block:: sh

  SCRIPT_PATH="$HOME/.skycluster/tailscale-cron.sh"
  mkdir -p "$HOME/.skycluster"

  # download the cron script
  curl -fsSL https://skycluster.io/configs/tailscale-cron.sh -o $SCRIPT_PATH
  chmod +x $SCRIPT_PATH

  # backup existing cron jobs
  crontab -u $USER -l 2>/dev/null > /tmp/mycron || true

  # add the cron job to run the script every 5 minutes
  echo "*/5 * * * * $SCRIPT_PATH" >> /tmp/mycron
  crontab -u $USER /tmp/mycron


.. note::

  You are now ready to initialize the providers and deploy your workload. To get started, see the examples in
  :doc:`/examples/index`.