# KIWI appliances

This repository contains two
[KIWI](https://en.opensuse.org/Portal:KIWI) virtual appliance image
definitions which are used to build `.vmdk` virtual disks.  These will
then be converted into Vagrant boxes which are used to build a whole
cloud via Vagrant.

Here's [a quick introduction to KIWI](http://doc.opensuse.org/projects/kiwi/doc/#chap.introduction)
in case you need it.

## Installing KIWI

Unfortunately KIWI currently only runs on SUSE-based systems.  There
is definitely appetite to port it to other distributions but noone has
had the time to do so yet.  Another interesting option for the future
would be to rebuild this appliance using [Packer](http://www.packer.io/).
[Pull requests](https://help.github.com/articles/using-pull-requests)
are very welcome - just [fork this repository](https://github.com/fghaas/openstacksummit2014-atlanta/fork)!

1.  If you're on SLES11 SP3, add the openSUSE:Tools repository first
    to get the latest KIWI version.  For example:

        sudo zypper ar http://download.opensuse.org/repositories/openSUSE:/Tools/SLE_11_SP3/ openSUSE:Tools

    If you're on openSUSE 13.1, you should already have the Updates
    repository containing the latest KIWI version.

2.  Now install the required KIWI packages:

        sudo zypper in kiwi kiwi-desc-vmxboot

## Building the virtual appliances

There are two different virtual appliances defined within this
subdirectory:

*   [`cloud3-admin`](cloud3-admin/) - the SUSE Cloud 3 admin node,
    which runs Crowbar and Chef, and
*   [`sles11-sp3`](sles11-sp3/) - a cut-down preload image of SUSE Linux
    Enterprise Server (SLES) 11 SP3, which will be used to provision
    two controller nodes (forming an HA cluster), and a compute node.

Instructions for building them are contained within the READMEs in
those subdirectories.
