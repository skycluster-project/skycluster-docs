.. toctree::
  :hidden:

Configurations
##############


Provider ConfigMaps
===================

.. container:: toggle open

  .. container:: header open

    **provider-vm.yaml**

  .. code-block:: yaml
    :emphasize-lines: 1
    :linenos:

    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: azure-canadaeast-default
      namespace: skycluster-system
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/config-type: provider-vars 
        skycluster.io/provider-name: azure
        skycluster.io/provider-region: canadaeast
        skycluster.io/provider-zone: default
    data:
      image-ubuntu-18.04-sku: 18_04-lts-gen2
      image-ubuntu-18.04-offer: UbuntuServer
      image-ubuntu-18.04-version: 18.04.202401161
      image-ubuntu-18.04-publisher: Canonical
      image-ubuntu-20.04-sku: 20_04-lts-gen2
      image-ubuntu-20.04-offer: 0001-com-ubuntu-server-focal
      image-ubuntu-20.04-version: 20.04.202406140
      image-ubuntu-20.04-publisher: Canonical
      image-ubuntu-22.04-sku: 22_04-lts-gen2
      image-ubuntu-22.04-offer: 0001-com-ubuntu-server-jammy
      image-ubuntu-22.04-version: 22.04.202406140
      image-ubuntu-22.04-publisher: Canonical
      flavor-small: "Standard_B2s"
      flavor-medium: "Standard_B2ms"
      flavor-large: "Standard_B4ms"
      flavor-xlarge: "Standard_B8ms"
      flavor-x.8G: "Standard_B2ms"
      flavor-x.16G: "Standard_B4ms"
      flavor-x.32G: "Standard_B8ms"
      # The default zone is not applicable in Azure
      # Azure has restrictions on the availability of 
      # certain instance types, images, public IPs and other resources
      # in certain zones, so we don't specify a default zone
      # We just need to make sure the location (region) supports the requirement
      # and let Azure pick the zone for us.
      default-zone: default
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: azure-canadacentral-default
      namespace: skycluster-system
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/config-type: provider-vars 
        skycluster.io/provider-name: azure
        skycluster.io/provider-region: canadacentral
        skycluster.io/provider-zone: default
    data:
      image-ubuntu-18.04-sku: 18_04-lts-gen2
      image-ubuntu-18.04-offer: UbuntuServer
      image-ubuntu-18.04-version: 18.04.202401161
      image-ubuntu-18.04-publisher: Canonical
      image-ubuntu-20.04-sku: 20_04-lts-gen2
      image-ubuntu-20.04-offer: 0001-com-ubuntu-server-focal
      image-ubuntu-20.04-version: 20.04.202406140
      image-ubuntu-20.04-publisher: Canonical
      image-ubuntu-22.04-sku: 22_04-lts-gen2
      image-ubuntu-22.04-offer: 0001-com-ubuntu-server-jammy
      image-ubuntu-22.04-version: 22.04.202406140
      image-ubuntu-22.04-publisher: Canonical
      flavor-small: "Standard_B2s"
      flavor-medium: "Standard_B2ms"
      flavor-large: "Standard_B4ms"
      flavor-xlarge: "Standard_B8ms"
      flavor-x.8G: "Standard_B2ms"
      flavor-x.16G: "Standard_B4ms"
      flavor-x.32G: "Standard_B8ms"
      # The default zone is not applicable in Azure
      # Azure has restrictions on the availability of 
      # certain instance types, images, public IPs and other resources
      # in certain zones, so we don't specify a default zone
      # We just need to make sure the location (region) supports the requirement
      # and let Azure pick the zone for us.
      default-zone: default
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: azure-centralus-default
      namespace: skycluster-system
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/config-type: provider-vars 
        skycluster.io/provider-name: azure
        skycluster.io/provider-region: centralus
        skycluster.io/provider-zone: default
    data:
      image-ubuntu-18.04-sku: 18_04-lts-gen2
      image-ubuntu-18.04-offer: UbuntuServer
      image-ubuntu-18.04-version: 18.04.202401161
      image-ubuntu-18.04-publisher: Canonical
      image-ubuntu-20.04-sku: 20_04-lts-gen2
      image-ubuntu-20.04-offer: 0001-com-ubuntu-server-focal
      image-ubuntu-20.04-version: 20.04.202406140
      image-ubuntu-20.04-publisher: Canonical
      image-ubuntu-22.04-sku: 22_04-lts-gen2
      image-ubuntu-22.04-offer: 0001-com-ubuntu-server-jammy
      image-ubuntu-22.04-version: 22.04.202406140
      image-ubuntu-22.04-publisher: Canonical
      flavor-small: "Standard_B2s"
      flavor-medium: "Standard_B2ms"
      flavor-large: "Standard_B4ms"
      flavor-xlarge: "Standard_B8ms"
      flavor-x.8G: "Standard_B2ms"
      flavor-x.16G: "Standard_B4ms"
      flavor-x.32G: "Standard_B8ms"
      # The default zone is not applicable in Azure
      # Azure has restrictions on the availability of 
      # certain instance types, images, public IPs and other resources
      # in certain zones, so we don't specify a default zone
      # We just need to make sure the location (region) supports the requirement
      # and let Azure pick the zone for us.
      default-zone: default
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: gcp-global
      namespace: skycluster-system
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/config-type: provider-vars 
        skycluster.io/provider-name: gcp
        skycluster.io/provider-region: global # will be global if not provided
        skycluster.io/provider-zone: default # will be default if not provided
    data:
      image-ubuntu-22.04: "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      image-ubuntu-20.04: "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
      image-ubuntu-18.04: "projects/ubuntu-os-cloud/global/images/family/ubuntu-1804-lts"
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: gcp-us-east1-default
      namespace: skycluster-system
      labels:
        skycluster.io/managed-by: skycluster
        skycluster.io/config-type: provider-vars 
        skycluster.io/provider-name: gcp
        skycluster.io/provider-region: us-east1
        skycluster.io/provider-zone: default
    data:
      default-zone: b
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-gcp-us-east1-b
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: gcp
        provider-region: us-east1
        provider-zone: b
    data:
      flavor-small: "e2-small"
      flavor-medium: "e2-medium"
      flavor-large: "e2-standard-2"
      flavor-xlarge: "e2-standard-4"
      flavor-x.8G: "e2-standard-2"
      flavor-x.16G: "e2-highmem-2"
      flavor-x.32G: "e2-highmem-4"
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-gcp-us-west1-default
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: gcp
        provider-region: us-west1
        provider-zone: default
    data:
      default-zone: b
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-gcp-us-west1-b
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: gcp
        provider-region: us-west1
        provider-zone: b
    data:
      flavor-small: "e2-small"
      flavor-medium: "e2-medium"
      flavor-large: "e2-standard-2"
      flavor-xlarge: "e2-standard-4"
      flavor-x.8G: "e2-standard-2"
      flavor-x.16G: "e2-highmem-2"
      flavor-x.32G: "e2-highmem-4"
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-savi-scinet-default
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: savi
        provider-region: scinet
        provider-zone: default
    data:
      flavor-small: m1.small
      flavor-medium: "m1.medium"
      flavor-large: "n1.medium"
      flavor-xlarge: "p2.large"
      flavor-x.8G: "n1.medium"
      flavor-x.16G: "o1.medium"
      flavor-x.32G: "p1.medium" 
      keypair: "skycluster-key"
      image-ubuntu-22.04: "Ubuntu-22-04-Jammy"
      image-ubuntu-20.04: "Ubuntu-20-04-focal"
      image-ubuntu-18.04: "Ubuntu-18-04-bionic"
      default-zone: default
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-savi-vaughan-default
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: savi
        provider-region: vaughan
        provider-zone: default
    data:
      flavor-small: "m1.small"
      flavor-medium: "m1.medium"
      flavor-large: "n1.medium"
      flavor-xlarge: "m1.large16"
      flavor-x.8G: "n1.medium"
      flavor-x.16G: "o1.medium"
      flavor-x.32G: "p1.medium" 
      keypair: "skycluster-key"
      image-ubuntu-22.04: "Ubuntu-22-04-Jammy"
      image-ubuntu-20.04: "Ubuntu-20-04-focal"
      image-ubuntu-18.04: "Ubuntu-18-04-bionic"
      default-zone: default
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-aws-us-east-1-default
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: aws
        provider-region: us-east-1
        provider-zone: default
    data:
      image-ubuntu-24.04: "ami-0980c117fa7ebaffd"
      image-ubuntu-22.04: "ami-07543813a68cc4fe9"
      image-ubuntu-20.04: "ami-0f81732f07ce19b1c"
      image-ubuntu-18.04: "ami-03025bb25a1de0fc2"
      default-zone: use1-az1
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-aws-us-east-1-use1-az1
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: aws
        provider-region: us-east-1
        provider-zone: use1-az1
    data:
      flavor-small: "t2.small"
      flavor-medium: "t2.medium"
      flavor-large: "t2.large" 
      flavor-xlarge: "t2.xlarge"
      flavor-x.8G: "t2.large" 
      flavor-x.16G: "t2.xlarge" 
      flavor-x.32G: "t2.2xlarge"
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-aws-us-east-1-use1-az2
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: aws
        provider-region: us-east-1
        provider-zone: use1-az2
    data:
      flavor-small: "t2.small"
      flavor-medium: "t2.medium"
      flavor-large: "t2.large" 
      flavor-xlarge: "t2.xlarge"
      flavor-x.8G: "t2.large" 
      flavor-x.16G: "t2.xlarge" 
      flavor-x.32G: "t2.2xlarge"
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-aws-ca-central-1-default
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: aws
        provider-region: ca-central-1
        provider-zone: default
    data:
      image-ubuntu-24.04: "ami-0e5eefaa7cc5ad3cc"
      image-ubuntu-22.04: "ami-0de67a2642184f666"
      image-ubuntu-20.04: "ami-0e0ac272cd74bdb14"
      image-ubuntu-18.04: "ami-0a7d5421816e931c8"
      default-zone: cac1-az1
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-aws-ca-central-1-cac1-az1
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: aws
        provider-region: ca-central-1
        provider-zone: cac1-az1
    data:
      flavor-small: "t2.small"
      flavor-medium: "t2.medium"
      flavor-large: "t2.large" 
      flavor-xlarge: "t2.xlarge"
      flavor-x.8G: "t2.large" 
      flavor-x.16G: "t2.xlarge" 
      flavor-x.32G: "t2.2xlarge"
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: vars-aws-ca-central-1-cac1-az2
      labels:
        managed-by: skycluster
        skycluster/config-type: provider-vars 
        provider-name: aws
        provider-region: ca-central-1
        provider-zone: cac1-az2
    data:
      flavor-small: "t2.small"
      flavor-medium: "t2.medium"
      flavor-large: "t2.large" 
      flavor-xlarge: "t2.xlarge"
      flavor-x.8G: "t2.large" 
      flavor-x.16G: "t2.xlarge" 
      flavor-x.32G: "t2.2xlarge"
    ---