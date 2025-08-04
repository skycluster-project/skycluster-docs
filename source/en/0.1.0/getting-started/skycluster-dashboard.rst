SkyCluster Dashboard
************************

.. toctree::
  :hidden:

The SkyCluster dashboard is a web-based user interface that allows you to manage and monitor your SkyCluster deployments. Please refer to the project github repository for issues and updates related to the dashboard. To install the dashboard, follow these steps:


Prerequisites
=============

If you use ``kind`` to run your Kubernetes cluster, make sure you have a load balancer such as `Kind LoadBalancer <https://kind.sigs.k8s.io/docs/user/loadbalancer/>`_ configured. This is necessary for the SkyCluster dashboard to be accessible via a LoadBalancer service.

Installation
===============

The SkyCluster dashboard is automatically deployed with the SkyCluster operator. If you have already installed the operator, you can skip the installation steps below. Check the status of
dashboard deployment by running the following command and ensure the same namespace is used as the operator:

.. code-block:: sh

    # Check the status of the dashboard deployment
    kubectl get deployment skycluster-dashboard -n skycluster

    # Check the status of the dashboard service
    kubectl get svc skycluster-dashboard -n skycluster

Please note the ``EXTERNAL-IP`` of the service, as you will need it to access the dashboard. If the EXTERNAL-IP is still pending, it means the LoadBalancer is not yet ready. CHeck the status of the 
LoadBalancer installation.

Manual Installation
-------------------

To manually install the SkyCluster dashboard, apply the following configuration to your Kubernetes cluster. This configuration creates a deployment and a service for the dashboard:

.. code-block:: yaml

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: skycluster-dashboard
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: skycluster-dashboard
      template:
        metadata:
          labels:
            app: skycluster-dashboard
        spec:
          serviceAccountName: skycluster-sva
          containers:
          - name: skycluster-dashboard
            image: etesami/skycluster-dashboard:latest
            ports:
            - containerPort: 8090
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: skycluster-dashboard
    spec:
      selector:
        app: skycluster-dashboard
      ports:
      - protocol: TCP
        port: 80
        targetPort: 8090
      type: LoadBalancer

    
Apply the above configuration to your Kubernetes cluster using kubectl and once the dashboard is running, you can access it via the LoadBalancer IP address.

.. code-block:: sh

    kubectl apply -f skycluster-dashboard.yaml
    kubectl get svc skycluster-dashboard

