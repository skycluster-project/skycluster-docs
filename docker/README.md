# Docker Setup
Follow the steps below to create an environment for development:

1. Build the docker image:
```bash
cd skycluster/docker
sudo docker build . -t skycluster-web:latest
```
2. Run a container using the built image:
```bash
sudo docker run -ti --rm -v ./:/skycluster -p 8000:8000 skycluster-web:latest
```
3. Inside the container use the following command or `server` as an alias,
to automaticall watch source files and render html output:
```bash
cd /skycluster # root directory
sphinx-autobuild . _build/html --host 0.0.0.0
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

In the `Makefile` `SOURCEDIR` shoud point to the `source` directory.





