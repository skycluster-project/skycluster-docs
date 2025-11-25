# Stage 1: Builder
FROM python:3.12-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /skycluster

# Install build dependencies and git
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python -m pip install --upgrade pip


# Install Python dependencies into /install
RUN pip install --prefix=/install --no-cache-dir \
    sphinx \
    sphinx-autobuild \
    pydata-sphinx-theme \
    sphinx-copybutton \
    sphinx-reredirects \
    sphinx-sitemap \
    sphinx-design \
    git+https://github.com/etesami/sphinx-tabs.git@robuster_dark_mode_detection \
    sphinx-multiversion

# Stage 2: Final lightweight image
FROM python:3.12-slim

WORKDIR /skycluster

# Install git (needed by sphinx-multiversion at runtime)
RUN apt-get update && apt-get install -y --no-install-recommends git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

COPY build-docs.sh /usr/local/bin/build-docs.sh
RUN chmod +x /usr/local/bin/build-docs.sh


# Set default entrypoint
ENTRYPOINT ["/usr/local/bin/build-docs.sh"]