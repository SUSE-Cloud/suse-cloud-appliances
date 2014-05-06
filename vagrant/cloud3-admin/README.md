# Vagrant box for Crowbar admin node

## Building the box

First you need to build the `.vmdk` as detailed in
[the README for the corresponding KIWI appliance](../../kiwi/cloud3-admin/README.md).

Then, `cd` to the directory containing this README, and type:

    make

This will create the `.box` file in the current directory, which you
can then install the Vagrant box via:

    vagrant box add cloud3-admin.json
