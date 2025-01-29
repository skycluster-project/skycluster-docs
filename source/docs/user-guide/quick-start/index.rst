Quick Start
############

.. toctree::
  :hidden:
  

**Application Definition**:

A couple of hello world examples.

.. code-block:: yaml

  apiVersion: core.skycluster-manager.skycluster.io/v1alpha1
  kind: SkyApp
  metadata:
    name: skyapp1
  spec:
    appConfig:
    - constraints:
        locationConstraints:
        - providerType: edge # near-the-edge, cloud
          # providerName: # aws, azure, gcp, ...
          # region: # us-west, us-east, ...
        virtualServiceConstraints:
        - virtualServiceName: skyk8scluster
      name: c1
    - constraints:
        locationConstraints:
        - providerType: cloud
        virtualServiceConstraints:
        - virtualServiceName: skyk8scluster
      name: c2
    - constraints:
        locationConstraints:
        - providerType: cloud
        virtualServiceConstraints:
        - virtualServiceName: skyk8scluster
      name: c3
    - constraints:
        locationConstraints:
        - providerType: cloud
        virtualServiceConstraints:
        - virtualServiceName: skyk8scluster
      name: c4
    - constraints:
        locationConstraints:
        - providerType: near-the-edge
        virtualServiceConstraints:
        - virtualServiceName: skyk8scluster
      name: c5
    appName: skyapp1

**Application Dataflow**:

.. code-block:: yaml

  apiVersion: core.skycluster-manager.skycluster.io/v1alpha1
  kind: DataflowAttribute
  metadata:
    name: skyapp1
  spec:
    appName: skyapp1
    connections:
    - destinations:
      - constraints:
          latency: 900ms
        name: c3
      - constraints:
          latency: 900ms
        name: c2
      source: c1
    - destinations:
      - constraints:
          latency: 909ms
        name: c4
      source: c2
    - destinations:
      - constraints:
          latency: 900ms
        name: c5
      source: c3
    - destinations:
      - constraints:
          latency: 900ms
        name: c5
      source: c4
