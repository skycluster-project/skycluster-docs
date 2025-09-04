#!/bin/sh
git config --global --add safe.directory /skycluster
exec sphinx-multiversion "$@"