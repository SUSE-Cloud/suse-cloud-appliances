# Running the HA demo on Windows

Here is a rough guide, but none of this has been tested yet.

    set VAGRANT_CONFIG_FILE=configs/2-controllers-1-compute.yaml
    set PROPOSALS_YAML=/root/HA-cloud.yaml

    REM Use these instead for 8GB:
    REM
    REM set VAGRANT_CONFIG_FILE=configs/2-controllers-0-compute.yaml
    REM set PROPOSALS_YAML=/root/HA-cloud-no-compute.yaml

Make sure you are in the right directory!

    cd path\to\git\repository
    cd vagrant

If you are not in the directory which contains `Vagrantfile`,
`configs/` etc. then the following will not work!

    vagrant up --no-parallel

FIXME: what next?  This probably won't work:

    vagrant ssh admin
    sudo bash

    setup-node-aliases.sh
    node-sh-vars > /tmp/.crowbar-nodes-roles.cache

    crowbar batch build /root/HA-cloud.yaml
