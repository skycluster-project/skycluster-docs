xProvider Resource
==================


.. code-block:: yaml

  # Unique identifier for the setup/application
  applicationId: aws-us-east
  
  vpcCidr: 10.40.0.0/16
  # Subnet CIDRs should be within the VPC CIDR range
  subnets:
    - type: public
      # Ensure the subnet CIDR range is within the VPC CIDR range
      # and does not overlap with other subnets and is 
      # appropriately sized for the expected number of resources
      # in this example, we reserve the half of the IPs
      cidr: 10.40.0.0/19	
      zone: us-east-1a
    - type: private
      cidr: 10.40.32.0/19	
      # Some services such as EKS require multiple availability zones
      # so we define a secondary zone here
      zone: us-east-1b
  gateway:
    # Flavor is defined as the number of vCPUs and memory
    flavor: 2vCPU-4GB
    volumeType: gp2
    volumeSize: 20
    
  providerRef:
    platform: aws
    region: us-east-1
    zones:
      # The provider is identified by the primary zone
      # Secondary zones are used for high availability or services
      # that require multiple availability zones such as EKS
      primary: us-east-1a
      secondary: us-east-1b