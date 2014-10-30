# FAQ

Here are some commonly encountered issues, and suggested solutions.
If none of them help, try this [guide to debugging](debugging.md).

## Vagrant tells me to run `vagrant init`

You're running `vagrant` from the wrong directory.  You should be
in the [`vagrant/` subdirectory of the git repository](../vagrant/),
which contains the `Vagrantfile`, the `demos/` subdirectory etc.

## I have issues with Vagrant and libvirt

Please check [this `vagrant-libvirt` page](vagrant-libvirt.md).

## One of my Crowbar controller nodes won't rejoin the HA cluster

Please see [this guide to cluster recovery](../demos/HA/cluster-recovery.md).

## I get a GRUB error on boot of a VM

Most likely your box download got corrupted or truncated.
