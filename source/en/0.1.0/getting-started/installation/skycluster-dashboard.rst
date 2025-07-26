SkyCluster Dashboard
************************

.. toctree::
  :hidden:


Installation
=================

The SkyCluster dashboard is a web-based user interface that allows you to manage and monitor your SkyCluster deployments. Please refer to the project github repository for issues and updates related to the dashboard. To install the dashboard, follow these steps:

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

.. code-block:: bash
    kubectl apply -f skycluster-dashboard.yaml
    kubectl get svc skycluster-dashboard

