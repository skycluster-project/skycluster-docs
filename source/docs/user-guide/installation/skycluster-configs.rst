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


SkyCluster Post-installation Configuration
==========================================

After installing SkyCluster, you need to configure the providers you want to use.
This includes setting up OpenStack providers and setting the latencies between registered regions and zones.  

SkyCluster OpenStack Provider Configuration
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
          - name: <TO_BE_REPLACED>
            region: <TO_BE_REPLACED>
            regionAlias: <TO_BE_REPLACED>
            subnetCidr: A.B.C.D/Y
            zones:
              - name: main
                locationName: <TO_BE_REPLACED>
                defaultZone: true|false
                type: cloud|nte|edge
                flavors: 
                  flavor-small:  <TO_BE_REPLACED>
                  flavor-medium: <TO_BE_REPLACED>
                  flavor-large:  <TO_BE_REPLACED>
                  flavor-xlarge: <TO_BE_REPLACED>
                  flavor-x.8G:   <TO_BE_REPLACED>
                  flavor-x.16G:  <TO_BE_REPLACED>
                  flavor-x.32G:  <TO_BE_REPLACED>
            images: 
              image-ubuntu-22.04: <TO_BE_REPLACED>
              image-ubuntu-20.04: <TO_BE_REPLACED>
              image-ubuntu-18.04: <TO_BE_REPLACED>

We use the following settings for the SAVI testbed.

.. container:: toggle 

  .. container:: header 

    **os-provider-setting.yaml**

  .. code-block:: yaml
    :linenos:

    providerMappings:
      openstack:
        regions:
          - name: scient
            region: scinet
            regionAlias: scinet
            subnetCidr: 10.30.10.0/24
            zones:
              - name: main
                locationName: Toronto
                defaultZone: true
                type: cloud
                flavors: 
                  flavor-small:  "n1.small"
                  flavor-medium: "o1.medium"
                  flavor-large:  "p1.medium"
                  flavor-xlarge: "p3.large"
                  flavor-x.8G:   "n1.medium"
                  flavor-x.16G:  "o1.medium"
                  flavor-x.32G:  "p1.medium" 
            images: 
              image-ubuntu-22.04: "Ubuntu-22-04-Jammy"
              image-ubuntu-20.04: "Ubuntu-20-04-focal"
              image-ubuntu-18.04: "Ubuntu-18-04-bionic"
          - name: vaughan
            region: vaughan
            regionAlias: vaughan
            subnetCidr: 10.29.10.0/24
            zones:
              - name: main
                locationName: Toronto
                defaultZone: true
                type: cloud
                flavors: 
                  flavor-small:  "n1.small"
                  flavor-medium: "o1.medium"
                  flavor-large:  "p1.medium"
                  flavor-xlarge: "p1.medium"
                  flavor-x.8G:   "n1.medium"
                  flavor-x.16G:  "o1.medium"
                  flavor-x.32G:  "p1.medium"  
            images: 
              image-ubuntu-22.04: "Ubuntu-22-04-Jammy"
              image-ubuntu-20.04: "Ubuntu-20-04-focal"
              image-ubuntu-18.04: "Ubuntu-18-04-bionic"


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
  | NTE    | Edge        | 15ms    |
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
