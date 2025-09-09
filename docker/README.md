# Docker Setup
Follow the steps below to create an environment for development:

1. Build the docker image:

```bash
cd skycluster-docs/docker
sudo docker build . -t etesami/sphinx-thin:latest
# or pull the image
sudo docker pull etesami/sphinx-thin:latest
```

2. Run a container using the built image:

```bash
sudo docker run -ti --rm -v ./:/skycluster -p 8000:8000 --entrypoint /bin/bash etesami/sphinx-thin:latest
```

3. Inside the container use the following command or `server` as an alias,
to watch source files and render html output:

```bash
cd /skycluster # root directory

# To serve and check the generated output:
python3 -m http.server 8000 --directory _build/html/latest

# For all other local development and testing use:
sphinx-autobuild source/ _build/html/dev --host 0.0.0.0
# Where it generates a rendered version of the local files into dev.
# or sphinx-build source _build/html -E
```


## Additional Notes

### Setting up the sphinx

```bash
sphinx-quickstart --ext-githubpages --ext-ifconfig \
  --extensions sphinx.ext.graphviz \
  --extensions sphinx.ext.extlinks \
  --extensions sphinx.ext.imgconverter \
  --quiet --makefile \
  -v v1alpha1 -a "Ehsan Etesami" -p "SkyCluster"
```

In the `Makefile`, `SOURCEDIR` should point to the `source` directory.


## Multi-versioning

```bash
# This creates a version-based pages, where the version is based on the branch or tag name
# This is handled through github actions when the latest branch is pushed.
# It looks for tags and generates the docs 
sphinx-multiversion  source _build/html/
```