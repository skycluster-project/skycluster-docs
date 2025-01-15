Providers Configuration
#######################

Providers such as ``AWS`` require authentication to manage 
external resources. For each provider integrated 
into the SkyCluster Manager, a separate configuration must be created.

AWS Configuration
=================

In the AWS Console, navigate to Identity and Access Management (IAM) 
and create a new user. Ensure the user has the following 
permission policy: ``AmazonEC2FullAceess``. 
Next, in the Security Credentials section, generate an access key. 
After obtaining the ``Access Key ID`` and ``Secret Access Key``, export them as
environmental variables and run the configuration script:


.. code-block:: sh

  export AWS_ACCESS_KEY_ID=abcd....xwyz # replace with your ID
  export AWS_SECRET_ACCESS_KEY=abcd....xwyz # replace with your Key


Execute the script shown below. For simplicity, you can alternatively run the following command:

.. code-block:: sh

  cd skycluster-manager
  ./config/provider-configs/aws-setup.sh

.. container:: toggle

  .. container:: header

    **aws-setup.sh**

  .. code-block:: sh

    #!/bin/bash

    # If env variables are not set, exit
    if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
      echo "AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set."
      exit 1
    fi

    # Create the content of the credentials in a variable
    creds_content="[default]
    aws_access_key_id = $AWS_ACCESS_KEY_ID
    aws_secret_access_key = $AWS_SECRET_ACCESS_KEY"

    # Echo the content and pipe it to base64 for encoding
    creds_enc=$(echo "$creds_content" | base64 -w0)

    cat <<EOF | kubectl apply -f -
    apiVersion: aws.upbound.io/v1beta1
    kind: ProviderConfig
    metadata:
      name: provider-cfg-aws
    spec:
      credentials:
        source: Secret
        secretRef:
          name: secret-aws
          namespace: crossplane-system
          key: creds
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: secret-aws
      namespace: crossplane-system
    type: Opaque
    data:
      creds: $creds_enc
    EOF


GCP Configuration
=================

Create a new project in Google Cloud, then add a service account. 
Generate a service account key file in JSON format and download the file. 
Then:

.. code-block:: sh

  # Use absolute path to the service account key file
  export GCP_SVC_ACC_PATH=/home/ubuntu/my-gcp-svc-acc.json
  export PROJECT_ID=my-gcp-project-id

Execute the script shown below. For simplicity, you can alternatively run the following command:

.. code-block:: sh

  cd skycluster-manager
  ./config/provider-configs/gcp-setup.sh 


.. container:: toggle

  .. container:: header

    **gcp-setup.sh**

  .. code-block:: sh

    #!/bin/bash

    if [[ -z "$GCP_SVC_ACC_PATH" ]] || [[ -z "$PROJECT_ID" ]] ; then
      echo "GCP_SVC_ACC_PATH and PROJECT_ID must be set."
      exit 1
    fi

    # if file does not exist, exit
    if [[ ! -f "$GCP_SVC_ACC_PATH" ]]; then
      echo "GCP_SVC_ACC_PATH File does not exist. Ensure the file exists and use the absolute path."
      exit 1
    fi

    kubectl create secret generic secret-gcp -n crossplane-system --from-file=creds=${GCP_SVC_ACC_PATH}

    # Apply the provider configuration
    cat <<EOF | kubectl apply -f -
    apiVersion: gcp.upbound.io/v1beta1
    kind: ProviderConfig
    metadata:
      name: provider-cfg-gcp
    spec:
      projectID: ${PROJECT_ID}
      credentials:
        source: Secret
        secretRef:
          namespace: crossplane-system
          name: secret-gcp
          key: creds
    EOF


Azure Configuration
===================

Create a subscription and note your Subscription ID. 
Next you will need to create a service principal and authentication file.
The easiest way to do this is through the ``CloudShell`` in the Azure portal.
Open the Azure portal and then run the following command in the CloudShell 
to create the service principal:

.. code-block:: sh

  export SUBS_ID=<subsc-id>
  az ad sp create-for-rbac --name skycluster-setup  \
    --role Owner \
    --scopes /subscriptions/${SUBS_ID} > azure_config.json
  
Download the ``azure_config.json`` file and export the path as an environmental variable:
For simplicity, you can run the following command or alternatively execute the script shown below.

.. code-block:: sh

  export AZURE_CONFIG_PATH=/home/ubuntu/azure_config.json
  cd skycluster-manager
  ./config/provider-configs/azure-setup.sh 

.. container:: toggle

  .. container:: header

    **azure-setup.sh**

  .. code-block:: sh
  
    #!/bin/bash
    
    if [[ ! -f $AZURE_CONFIG_PATH ]]; then
      echo "Azure config file not found at $AZURE_CONFIG_PATH"
      exit 1
    fi
    
    cont_enc=$(echo $AZURE_CONFIG_PATH | base64 -w0)
    
    cat <<EOF | kubectl apply -f -
    apiVersion: azure.upbound.io/v1beta1
    metadata:
      name: provider-cfg-azure
    kind: ProviderConfig
    spec:
      credentials:
        source: Secret
        secretRef:
          namespace: crossplane-system
          name: secret-azure
          key: creds
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: secret-azure
      namespace: crossplane-system
    type: Opaque
    data:
      creds: $cont_enc
    EOF

Openstack Configuration
========================

If you have on-premises infrastructure managed by Openstack you can follow the steps below:

.. code-block:: sh

  export AUTH_URL="url"
  export USERNAME="username"
  export PASSWORD="pass"
  export TENANT_NAME="project-name"
  export REGION="region"
  export USER_DOMAIN_NAME="Default"
  export PROJECT_DOMAIN_NAME="Default"

Execute the script shown below. For simplicity, you can alternatively run the following command:

.. code-block:: sh

  cd skycluster-manager
  ./config/provider-configs/openstack-setup.sh 

.. container:: toggle

  .. container:: header

    **openstack-setup.sh**

  .. code-block:: sh

    #!/bin/bash

    # Check if any of these variables are not set, if so exist
    if [[ -z $AUTH_URL || -z $USERNAME || -z $PASSWORD || -z $TENANT_NAME || \
      -z $REGION || -z $USER_DOMAIN_NAME || -z $PROJECT_DOMAIN_NAME ]]; then
      echo "One or more required variables are not set."
      exit 1
    fi
    
    cat <<EOF | kubectl apply -f -
    apiVersion: openstack.crossplane.io/v1beta1
    kind: ProviderConfig
    metadata:
      name: provider-cfg-os
    spec:
      credentials:
        source: Secret
        secretRef:
          name: secret-os
          namespace: crossplane-system
          key: configs
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: secret-os
      namespace: crossplane-system
    type: Opaque
    stringData:
      configs: |
        {
          "auth_url": $AUTH_URL,
          "user_name": $USERNAME,
          "password": $PASSWORD,
          "tenant_name": $TENANT_NAME,
          "region": $REGION,
          "user_domain_name": $USER_DOMAIN_NAME,
          "project_domain_name": $PROJECT_DOMAIN_NAME
        }
    EOF
    