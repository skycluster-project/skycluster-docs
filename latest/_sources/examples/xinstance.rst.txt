
Virtual Instance
##################

.. toctree::
  :hidden:

Now let's create a virtual instance using the provider instance we just created:

.. code-block:: yaml

    apiVersion: skycluster.io/v1alpha1
    kind: XInstance
    metadata:
      name: example-instance-us-east
    spec: 
      # Unique identifier for the setup/application
      # Must be same as the one used in the provider instance (for AWS)
      applicationId: aws-us-east
      
      flavor: 2vCPU-4GB
      
      # Images are defined by images.core.skycluster.io custom resources
      image: ubuntu-22.04
      
      # publicKey: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3...
      # Optional: the default public key is used if not specified

      # If publicIp set to true, a public IP will be assigned to the instance
      publicIp: false
      
      # Optional: the user data should follow the cloud-init format
      userData: |
        #cloud-config
        write_files:
          - path: /tmp/hello.sh
            owner: root:root
            permissions: '0755'
            content: |
              #!/bin/sh
              echo "Hello, World!" > /tmp/hello.txt
        runcmd:
          - chmod +x /tmp/hello.sh
          - /tmp/hello.sh
      
      # Optional: security groups can be defined to allow specific ports
      # securityGroups:
      #   tcpPorts:
      #     - fromPort: 22
      #       toPort: 22
      #       protocol: tcp
      #   udpPorts:
      #     - fromPort: 80
      #       toPort: 80
      #       protocol: udp

      # Optional
      # rootVolumes:
      #   - size: 20Gi
      #     type: gp2
      
      providerRef:
        # Provider reference must match the one used in the provider instance
        # (for AWS)
        platform: aws
        region: us-east-1
        zone: us-east-1a


.. note::

  Check the status of the ``XInstance`` resource by running the following command or through :doc:`/getting-started/skycluster-dashboard`.

  .. code-block:: sh

    kubectl get xinstances.skycluster.io
    # NAME                          SYNC     STATUS
    # example-instance-us-east      Ready    Ready

  You can also use the SkyCluster cli commadnd:

  .. code-block:: sh

    skycluster xinstance list
    # NAME                            PUBLIC_IP        PRIVATE_IP
    # example-kube-os-scinet-nd4qq                     10.16.128.12
    # example-kube-os-scinet-w4mtz    142.1.174.183    10.16.128.16

If you enable a public IP for your ``XInstance``, you can access it directly from anywhere
using the instance’s ``External IP``.  
Otherwise, the instance is accessible only via its private IP from the machine running the SkyCluster system.

You need to use the key described in the SkyCluster Secret configuration section of :doc:`/getting-started/installation`.

.. code-block:: sh

  ssh -i id_rsa ubuntu@<instance-ip>

