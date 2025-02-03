#!/bin/bash

# If env variables are not set, exit
if [ -z "$HEADSCALE_VERSION" ] || [ -z "$HEADSCALE_ARCH" ]; then
  echo "HEADSCALE_VERSION and HEADSCALE_ARCH must be set."
  exit 1
fi

wget --output-document=/tmp/headscale.deb \
    "https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${HEADSCALE_ARCH}.deb"
sudo dpkg -i /tmp/headscale.deb

