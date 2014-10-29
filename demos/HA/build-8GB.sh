#!/bin/bash

export VAGRANT_CONFIG_FILE=configs/2-controllers-0-compute.yaml
export PROPOSALS_YAML=/root/HA-cloud-no-compute.yaml

./build.sh "$@"
