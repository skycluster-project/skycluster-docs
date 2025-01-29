# Use the Ubuntu base image
FROM ubuntu:22.04

# Set environment variable to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    git \
    build-essential \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /skycluster

# Install Sphinx, sphinx-autobuild for live reload, and the PyData theme
RUN pip3 install --no-cache-dir sphinx sphinx-autobuild pydata-sphinx-theme sphinx-copybutton sphinx-reredirects

RUN echo 'alias server="sphinx-autobuild source _build/html --host 0.0.0.0"' >> ~/.bashrc
RUN echo 'alias build-all="sphinx-build source _build/html -E"' >> ~/.bashrc