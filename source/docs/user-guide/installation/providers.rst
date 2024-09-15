Provider Installation
######################

Providers installed in Crossplane require authentication to manage 
external resources. For each cloud provider that you want to integrate 
into the system, a separate configuration must be created.

Functions
==========

We need several functions that allow us to define composite resources:

.. code-block:: console

  cat <<EOF | kubectl apply -f -
  apiVersion: pkg.crossplane.io/v1beta1
  kind: Function
  metadata:
    name: function-go-templating
  spec:
    package: xpkg.upbound.io/crossplane-contrib/function-go-templating:v0.5.0
  ---
  apiVersion: pkg.crossplane.io/v1beta1
  kind: Function
  metadata:
    name: function-extra-resources
  spec:
    package: xpkg.upbound.io/crossplane-contrib/function-extra-resources:v0.0.3
  ---
  apiVersion: pkg.crossplane.io/v1beta1
  kind: Function
  metadata:
    name: function-auto-ready
  spec: 
    package: xpkg.upbound.io/crossplane-contrib/function-auto-ready:v0.2.1
  ---
  apiVersion: pkg.crossplane.io/v1beta1
  kind: Function
  metadata:
    name: function-patch-and-transform
  spec:
    package: xpkg.upbound.io/crossplane-contrib/function-patch-and-transform:v0.2.1
  EOF

AWS Configuration
=================

In the AWS Console, navigate to Identity and Access Management (IAM) 
and create a new user. Ensure the user has the following 
permission policy: ``AmazonEC2FullAceess``. 
Next, in the Security Credentials section, generate an access key. 
After obtaining the ``Access Key ID`` and ``Secret Access Key``, use the script 
below to create configuration for AWS:

.. code-block:: console

  AWS_ACCESS_KEY_ID=abcd....xwyz # replace with your ID
  AWS_SECRET_ACCESS_KEY=abcd....xwyz # replace with your Key

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
Generate a service account key file in JSON format. After that, 
use the script below:

.. code-block:: console

  kubectl create secret generic secret-gcp -n crossplane-system --from-file=creds=./sv-acc.json

  # Apply the provider configuration
  cat <<EOF | kubectl apply -f -
  apiVersion: gcp.upbound.io/v1beta1
  kind: ProviderConfig
  metadata:
    name: provider-cfg-gcp
  spec:
    projectID: learned-cosine-391615
    credentials:
      source: Secret
      secretRef:
        namespace: crossplane-system
        name: secret-gcp
        key: creds
  EOF

Azure Configuration
===================

Create a subscription and note your Subscription ID. Next, create a 
service principal and configure its access to Azure resources. 
This can be done using the ``az`` CLI tool. Follow the script below:

.. code-block:: console

  export SUBS=<subsc-id> # replace with your subscription id
  az account set --subscription $SUBS
  cont_json=$(az ad sp create-for-rbac --sdk-auth --role Owner \
    --scopes /subscriptions/$SUBS)
  cont_enc=$(echo $cont_json | base64 -w0)

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

.. code-block:: console

  AUTH_URL="url"
  USERNAME="username"
  PASSWORD="pass"
  TENANT_NAME="project-name"
  REGION="region"
  USER_DOMAIN_NAME="Default"
  PROJECT_DOMAIN_NAME="Default"

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