# KIWI appliances

This repository contains two
[KIWI](https://en.opensuse.org/Portal:KIWI) virtual appliance image
definitions which are used to build `.vmdk` virtual disks.  These will
then be converted into Vagrant boxes which are used to build a whole
cloud via Vagrant.

Here's [a quick introduction to KIWI](http://doc.opensuse.org/projects/kiwi/doc/#chap.introduction)
in case you need it.

There are two different virtual appliances defined within this
subdirectory:

*   [`cloud3-admin`](cloud3-admin/) - the SUSE Cloud 3 admin node,
    which runs Crowbar and Chef, and
*   [`sles11-sp3`](sles11-sp3/) - a cut-down preload image of SUSE Linux
    Enterprise Server (SLES) 11 SP3, which will be used to provision
    two controller nodes (forming an HA cluster), and a compute node.
