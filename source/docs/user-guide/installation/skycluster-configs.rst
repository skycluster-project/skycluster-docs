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


SkyCluster Private Image Reposity
==================================

You can use your private registry when deploying Kubernetes clusters using SkyCluster.
To do so, you need to create a secret containing the credentials for the private registry.
The secret should be created in the ``skycluster`` namespace.

First export your registry credentials, you need to first run ``sudo docker login <registry>`` to login to your private registry.
Then use the credentials created in the ``~/.docker/config.json`` or ``/root/.docker/config.json`` file to create the secret:

.. code-block:: sh

  # in this example we use /root/.docker/config.json
  kubectl create secret generic regcred  \
    --from-file=.dockerconfigjson=/root/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson \
    -n skycluster

  # Make sure to label the secret
  kubectl label secret regcred \
    skycluster.io/secret-type=registry \
    skycluster.io/managed-by=skycluster \
    -n skycluster


SkyCluster Post-installation Configuration
==========================================

After installing SkyCluster, you need to configure the providers you want to use.
This includes setting up OpenStack providers and setting the latencies between registered regions and zones.  

SkyCluster AWS Configuration
-------------------------------------------

.. note::
  This step is only required if you are using AWS and have enalbed it 
  during the installation of SkyCluster.

You need to create a YAML file containing the essential mapping information for the provider.
Below you can find an exmaple ``YAML`` file for the AWS provider configuration.

.. container:: toggle open

  .. container:: header open

    **aws-provider-setting.yaml**

  .. code-block:: yaml
    :linenos:

    providerMappings:
      aws:
        # global field is reserved for future use anf global settings       
        global:
        regions:
          - name: aws_us-east-1_cloud_VI
            region: us-east-1
            continent: NorthAmerica
            regionAlias: us-east
            zones:
              # We need to ensure for each region, there is one zone
              # with defaultZone set to true
              - name: use1-az1
                locationName: Virginia
                defaultZone: true
                type: cloud
                defaults:
                  flavor: 2vCPU-4GB
                  min-vCPU: 1vCPU-2GB
                  max-vCPU: 8vCPU-32GB
                  image: ubuntu-24.04
                storage:
                  - name: BlockStorage
                    type: EBS
                    min: 10GB
                    step: 10GB
                    price: 0.8
                flavors: 
                  - flavor: 1vCPU-2GB
                    name: t2.small
                    vcpus: 1
                    ram: 2GB
                    price: 0.032
                  - flavor: 2vCPU-4GB
                    name: t3.medium
                    vcpus: 2
                    ram: 4GB
                    price: 0.0416
                egressDataTransfer:
                  - name: Internet
                    # type refers to the destination type of the traffic.
                    # possible options are "Internet" for egres traffic 
                    # through Internet and "Provider" for direct traffic 
                    # to another provider. 
                    # Currently only "Internet" is supported
                    type: Internet 
                    price: 0.09
            # images specifies the mapping between the image names
            # and the actual image names in the OpenStack provider
            # within this <region>. We assume images are available
            # in all zones within the region.
            images: 
              ubuntu-24.04: ami-0980c117fa7ebaffd
              ubuntu-22.04: ami-07543813a68cc4fe9
              ubuntu-20.04: ami-0f81732f07ce19b1c



SkyCluster OpenStack Configuration
-------------------------------------------

.. note::
  This step is only required if you are using OpenStack and have enalbed it 
  during the installation of SkyCluster.

For each OpenStack provider, you need to create a YAML file containing the 
essential mapping information for the provider. Use the YAML template below
and provide the appropriate values for each field:

.. container:: toggle open

  .. container:: header open

    **os-provider-setting.yaml**

  .. code-block:: yaml
    :linenos:

    providerMappings:
      openstack:
        regions:
          - name:  # Name of the region
            region: # Name of the region
            regionAlias: # Alias of the region
            continent: NorthAmerica
            zones:
              # There should be at least one zone specified as default for each region
              - name: zone-1
                locationName: Toronto
                # the default zone is identified by setting 
                # the defaultZone to true
                defaultZone: true
                type: cloud
                defaults:
                  flavor: p2.large
                  image: ubuntu-22.04
                  min-vCPU: 1vCPU-2GB
                  max-vCPU: 12vCPU-32GB
                egressDataTransfer:
                  - name: Internet
                    type: Internet 
                    price: 0.02
                storage:
                  - name: BlockStorage
                    type: EBS
                    min: 10GB
                    step: 10GB
                    price: 0.8
                # flavors specifies the mapping between the flavor names
                # and the actual machine types in the OpenStack provider
                # within this <zone>. 
                flavors:
                    # name of the flavor in the provider
                  - name: m1.small
                    # flavor is the name of the flavor used in the SkyCluster
                    flavor: 1vCPU-2GB
                    vcpus: 1
                    ram: 2GB
                    price: 0.032
                  - name: m1.medium
                    flavor: 2vCPU-4GB
                    vcpus: 2
                    ram: 4GB
                    price: 0.02
            # images specifies the mapping between the image names
            # and the actual image names in the OpenStack provider
            # within this <region>. We assume images are available
            # in all zones within the region.
            images: 
              ubuntu-24.04: ubuntu-24.04
              ubuntu-22.04: ubuntu-22.04
              ubuntu-20.04: ubuntu-20.04
              ubuntu-18.04: ubuntu-18.04

We use the following settings for the SAVI testbed.

.. container:: toggle 

  .. container:: header 

    **os-provider-setting.yaml**

  .. code-block:: yaml
    :linenos:

    providerMappings:
      openstack:
        regions:
          - name: SCINET
            region: SCINET
            regionAlias: SCINET
            subnetCidr: 10.30.10.0/24
            gatewayIp: 10.30.10.1
            zones:
              - name: default
                locationName: Toronto
                defaultZone: true
                type: cloud
                flavors: 
                  small:  n1.small
                  medium: o1.medium
                  large:  p1.medium
                  xlarge: p3.large
                  x.8G:   n1.medium
                  x.16G:  o1.medium
                  x.32G:  p1.medium
            images: 
              ubuntu-22.04: Ubuntu-22-04-Jammy
              ubuntu-20.04: Ubuntu-20-04-focal
              ubuntu-18.04: Ubuntu-18-04-bionic
          - name: VAUGHAN
            region: VAUGHAN
            regionAlias: VAUGHAN
            subnetCidr: 10.29.10.0/24
            gatewayIp: 10.29.10.1
            zones:
              - name: default
                locationName: Toronto
                defaultZone: true
                type: cloud
                flavors: 
                  small:  n1.small
                  medium: o1.medium
                  large:  p1.medium
                  xlarge: p1.medium
                  x.8G:   n1.medium
                  x.16G:  o1.medium
                  x.32G:  p1.medium
            images: 
              ubuntu-22.04: Ubuntu-22-04-Jammy
              ubuntu-20.04: Ubuntu-20-04-focal
              ubuntu-18.04: Ubuntu-18-04-bionic


After creating the YAML file above, run the following command to configure the OpenStack provider:

.. code-block:: sh

  helm install skycluster skycluster/skycluster \
    --set postInstall=true -f os-provider-setting.yaml



Latency Configuration
---------------------

Currently, SkyCluster automatically configures the latencies between regions and zones.
The calculated latencies depends on the type and location of the provider.
Table below summarizes how the latencies is calculated between different regions and zones based on our experiments and measurements from AWS. We will introduce automatic latency measurement in future releases.

.. container:: toggle 

  .. container:: header 

    **Latency Calculations**

  Same Continents:

  +--------+-------------+---------+
  | Source | Destination | Latency |
  +========+=============+=========+
  | Cloud  | Cloud       | 100ms   |
  +--------+-------------+---------+
  | Cloud  | NTE         | 25ms    |
  +--------+-------------+---------+
  | Edge   | Edge        | 6ms     |
  +--------+-------------+---------+
  | NTE    | NTE         | 10ms    |
  +--------+-------------+---------+
  | NTE    | Edge        | 8ms     |
  +--------+-------------+---------+

  Different Continents, traffic between different continents is routed through the Cloud region. 

  +--------+-------------+---------+
  | Source | Destination | Latency |
  +========+=============+=========+
  | Cloud  | Cloud       | 200ms   |
  +--------+-------------+---------+


Crossplane Configuration
------------------------------------

SkyCluster utilizes Crossplane to manage the cloud resources.
We create a series of composition and XRDs and use them to build our
abstraction system on top of them. To install all required compositions
and XRDs, run the following command:

.. code-block:: sh

  curl -s http://skycluster.io:8000/crossplane/lists.txt | \
    while read url; do \
      curl -s "$url" | kubectl apply -f - ; done
