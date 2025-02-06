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
  :linenos:

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

.. container:: blockbox gray-sidebar

  .. container:: header

    **Within your overlay server:**

  .. code-block:: sh

    export HEADSCALE_VERSION="0.24.2" 
    export HEADSCALE_ARCH="amd64"
    
    # ensure you have sudo access, then
    curl -s https://skycluster.io/configs/headscale-install.sh | bash

**Alternatively** you can manuallly install headscale using the script below:

.. container:: toggle

  .. container:: header

    **headscale-install.sh**

  .. code-block:: sh
    :linenos:

    #!/bin/bash
    # If env variables are not set, exit
    if [ -z "$HEADSCALE_VERSION" ] || [ -z "$HEADSCALE_ARCH" ]; then
      echo "HEADSCALE_VERSION and HEADSCALE_ARCH must be set."
      exit 1
    fi

    wget --output-document=/tmp/headscale.deb \
        "https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${HEADSCALE_ARCH}.deb"
    sudo dpkg -i /tmp/headscale.deb


After successful installation, you need to configure headscale. Try script below 
to generate a configuration file, tls certificates and then start the headscale server:

.. container:: blockbox gray-sidebar

  .. container:: header

    **Within your overlay server:**

  .. code-block:: sh

    export PUBLIC_IP=$(curl -s ifconfig.io)
    curl -s https://skycluster.io/configs/headscale-cfg.sh | bash


Once done you should see a generated token along with 
a ``ca_certificate.crt``. You will need to use the certificate and token to configure
SkyCluster to allow providers to join the overlay network. 

Copy the ``ca_certificate.crt`` file to your SkyCluster environment where you have access to ``kubectl``, then
export the following environment variables: 

.. container:: blockbox orange-sidebar

  .. container:: header

    **Within your SkyCluster environment:**

  .. code-block:: sh

    # This is the public IP of you overlay server
    export HOST="$PUBLIC_IP_OVERLAY"
    export PORT="8080"

    # You get the token from the previous step
    export TOKEN="1bdff6711a9a49e...d6bd9b7c7dac4e"

    # CA_CERTIFICATE should be the path to the ca_certificate.crt file
    export CA_CERTIFICATE=$(PWD)/ca_certificate.crt

and then run the following command to create a secret containing this information:

.. container:: blockbox orange-sidebar

  .. container:: header

    **Within your SkyCluster environment:**

  .. code-block:: sh

    curl -s https://skycluster.io/configs/overlay-server-cfg.sh | bash


**Alternatively** you can just copy the script below and run it:

.. container:: toggle

  .. container:: header

    **overlay-server-cfg.sh**

  .. code-block:: sh
    :linenos:

    #!/bin/bash

    if [[ -z "$HOST" ]] || [[ -z "$TOKEN" ]] || [[ -z "$PORT" ]] || [[ -z $CA_CERTIFICATE ]]; then
      echo "HOST, TOKEN, PORT and CA_CERTIFICATE must be set."
      exit 1
    fi

    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Secret
    metadata:
      namespace: skycluster
      name: overlay-server-cfg
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/secret-type: overlay-server
    type: Opaque
    stringData:
      config: |
        {
          "host": "https://$HOST",
          "port": "$PORT",
          "token": "$TOKEN",
          "ca_cert": "$(cat $CA_CERTIFICATE | base64 -w0)"
        }
    EOF

You also need to join your SkyCluster to the overlay network:

.. container:: blockbox orange-sidebar

  .. container:: header

    **Within your SkyCluster environment:**

  .. code-block:: sh
    
    # First ensure the ca_certificate is installed
    sudo cp ${CA_CERTIFICATE} /usr/local/share/ca-certificates/
    # Update CA certificates
    sudo update-ca-certificates

    # Then join the overlay network
    # First ensure tailscale is installed
    curl -fsSL https://tailscale.com/install.sh | sh

    # Then join the netwotk
    sudo tailscale up --login-server=https://${HOST}:${PORT} --auth-key=${TOKEN}


You can always check the status of the clients by running the following commands on your overlay server:


.. container:: blockbox gray-sidebar

  .. container:: header

    **Within your overlay server:**

  .. code-block:: sh

    sudo headscale status
    sudo headscale nodes list


SkyCluster creates clients and will join them to the headscale server automatically.

