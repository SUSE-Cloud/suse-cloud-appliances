# Vagrant box for Crowbar client node

## Building the box

**N.B. [These instructions are now obsolete!](../README.md)**

First you need to build the `.vmdk` as detailed in
[the README for the corresponding KIWI appliance](../../../kiwi/sles12-sp1/README.md).

Then, `cd` to the directory containing this README, and type:

    make

This will create the `.box` file in the current directory, which you
can then install the Vagrant box via:

    vagrant box add sles12-sp1.json
