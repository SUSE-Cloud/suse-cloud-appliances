#!/bin/bash

# If you only have 8GB of RAM, source this file before running build.sh:
#
#   source ./build-8GB
#   ./build.sh virtualbox

export VAGRANT_CONFIG_FILE=configs/2-controllers-0-compute.yaml
export PROPOSALS_YAML=/root/HA-cloud-no-compute.yaml
