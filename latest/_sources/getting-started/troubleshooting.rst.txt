Troubleshooting
----------------


.. toctree::
  :hidden:


Essentials
================

Make sure `ProviderProfile` objects are properly configured and ready:

.. code-block:: sh

  kubectl get providerprofile
  # NAME                  PLATFORM    REGION      READY
  # aws-us-east-1         aws         us-east-1   True


If the ``READY`` status field is not ``TRUE`` check the corresponding ``InstanceType`` and ``Image`` resources:

.. code-block:: sh

  kget instancetypes.core
  # NAME                         REGION            READY   LAST_UPDATE
  # aws-us-east-1-q6t5b          us-east-1         True    2025-09-02T20:13:11Z

.. code-block:: sh

  kubectl get images.core
  # NAME                         REGION            READY   LAST_UPDATE
  # aws-us-east-1-j4nfk          us-east-1         True    2025-09-02T20:20:19Z

If the ``READY`` status field is not ``TRUE`` check the logs of skycluster-operator and open an issue.


Overlay Network Status
=================================

SKyCluster utilizes two plane to control services and resources. A management overlay network 
created by using tailscale/headscale combination creates tunnels across all providers and enables
access to services and resources using their private IP addresses. 

An inter-cluster network for workloads running on Kbernetes clusters, where pods and services are
reachable across all providers, SkyCluster utilizes Submariner to creates tunnels and coordinates between clusters.

To verify the network status check the status of the SkyCluster setup:

.. code-block:: sh

  kubectl get xsetups.skycluster.io
  # NAME        SYNCED   READY   COMPOSITION             AGE
  # mycluster   True     True    xsetups.skycluster.io   31d

You should see both ``SYNCED`` and ``READY`` status as ``True``. If not, there is an issue with the SkyCluster installation and setup. 

Then check the status of overlay setups, which includes the broker and headscale servers for creation and maintaining tunnels:

.. code-block:: sh

  kubectl get xoverlays.skycluster.io
  # NAME              SYNCED   READY   COMPOSITION               AGE
  # mycluster-jwdbc   True     True    xoverlays.skycluster.io   31d

If any of ``SYNCED`` or ``READY`` status is not ``True`` for overlay setups, there is an issue with the SkyCluster overlay network configuration.

SkyCluster uses the Tailscale client underlay to connect to the overlay, as described in :doc:`/getting-started/skycluster-configs`. Ensure that the routing and overlay setup status of the controller is up to date by running:

.. code-block:: sh

  # connect/reconnect to the overlay
  curl -s https://skycluster.io/configs/tailscale-connect.sh | bash
  
  # then check status by:
  sudo tailscale status
  # 100.64.0.12     skycluster-dev       skycluster   linux   -
  # 100.64.13.86    os-provider-scinet   skycluster   linux   active; direct 142.1.174.185:41641, tx 47252 rx 59364

If the connection does not establish, there is an issue with the overlay connection and setup.


