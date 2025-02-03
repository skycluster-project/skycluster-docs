Overlay Server Configuration
****************************

.. toctree::
  :hidden:


.. _TAILSCALE: https://tailscale.com
.. _HEADSCALE: https://github.com/juanfont/headscale

In order to enable communication between services and resources
across different providers, we utilize an overlay solution powered
by `Tailscale <TAILSCALE_>`_. In order to enable overlay functionality, you need to
setup a control server. Since tailscale controller is a prioprietary
service, we use `Headscale <HEADSCALE_>`_, as an open source, self-hosted implementation of the 
tailscale control server. Please follow the instructions below to setup
your headscale server and configure your skycluster to use it.

You can create a ``SkyVM`` instance within your desired provider and install
headscale on it. Below is an example of YAML file you would need to create an
instance:


.. code-block:: yaml

  apiVersion: xrds.skycluster.io/v1alpha1
  kind: SkyVM
  metadata:
    name: skyvm-overlay-server
    namespace: skytest
    labels:
      skycluster.io/managed-by: skycluster
  spec: 
    forProvider:
      assignPublicIp: false
    providerRef:
      providerName: aws
      providerRegion: us-east-1
      providerZone: use1-az1

      # You need to open inbound tcp ports "443 80 22 8080"
      # and inbound udp ports "3478 41641"

Once you have the VM running and ready, connect to it and then install headscale:

.. code-block:: sh


  export HEADSCALE_VERSION="0.24.2" 
  export HEADSCALE_ARCH="amd64"
  
  # ensure you have sudo access, then
  curl -s https://skycluster.io/configs/headscale-install.sh | bash
  
  # sudo systemctl enable --now headscale
  # sudo systemctl status headscale



.. code-block:: sh

  export PUBLIC_IP=$(curl -s ifconfig.io)
  curl -s https://skycluster.io/configs/headscale-cfg.sh | bash

Once ready run the service by:

.. code-block:: sh

  sudo headscale serve

SkyCluster creates clients and will join them to the headscale server automatically.
You can check the status of the clients by running:

.. code-block:: sh

  sudo headscale status
  sudo headscale nodes list


