# How to automatically deploy SUSE Cloud via Vagrant

## Prerequisites

*   Machine with >= 4GB RAM and >= roughly 16GB spare disk
    *   Ideally you should have 16GB RAM for building a full HA cloud.
    *   If you only have 8GB and want to build a two-node HA cluster
        for the control plane then you will not have enough RAM for a
        compute node in order to provision a VM instance in the cloud.
        However this is still plenty interesting enough to be worth
        attempting!  Alternatively you could opt for a single controller
        node in a non-HA configuration.
    *   If you only have 4GB, you will be able to run the Crowbar admin
        node but nothing else.  This is not very useful but at least
        lets you poke around the Crowbar UI.
*   [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 4.3.0
    (but the latest release is strongly recommended), or
    [`libvirt`](http://libvirt.org/) installed, including the development
    libraries, e.g.:

        zypper in libvirt libvirt-devel

*   [Vagrant](http://www.vagrantup.com/) >= 1.5.x installed (latest 1.6.x recommended)
*   if using `libvirt`,
    [`vagrant-libvirt` plugin](https://github.com/pradels/vagrant-libvirt) >= 0.20.0
    installed, e.g.:

        vagrant plugin install vagrant-libvirt

*   this git repository (see the [project page](../..) for URLs to use with `git clone`,
    or just [download a `.zip`](https://github.com/SUSE-Cloud/suse-cloud-vagrant/archive/master.zip))
*   the `suse/cloud4-admin` box (currently only [available to SUSE
    employees](https://etherpad.nue.suse.com/p/cloud-vagrant)
    but hopefully will be published on https://vagrantcloud.com/suse
    soon; please [contact us](https://forums.suse.com/forumdisplay.php?65-SUSE-Cloud)
    if you need a copy urgently
*   a `suse/sles11sp3` or `suse/sles11sp3-minimal` box; again please [contact
    us](https://forums.suse.com/forumdisplay.php?65-SUSE-Cloud) regarding this
    as work is currently in flux
*   an internet connection, or if you want to do this offline, you need
    to pre-download the two Vagrant boxes before you disconnect:

        vagrant box add suse/cloud4-admin
        vagrant box add suse/sles11sp3 # or suse/sles11sp3-minimal

## SUSE Cloud installation

*   If using VirtualBox:
    *   Start the GUI
    *   *File* → *Preferences* → *Network* then ensure you have:
        *   a single NAT network (in VirtualBox 4.2 this is hardcoded so
            don’t worry about it)
        *   a host-only network, named `vboxnet0`, with IP `192.168.124.1`
            and **DHCP disabled**.
*   Depending on what cloud configuration you desire, either use Vagrant
    to sequentially provision all four VMs from the default configuration
    (1 admin + 2 controllers + 1 compute node) in one go:

        cd vagrant
        vagrant up

    or keep reading to find out how to choose which VMs to
    provision.

There is always exactly one admin server node.  You can change the
number of controller nodes and compute notes from the defaults of 2
and 1 respectively by exporting environment variables, e.g.:

    export VAGRANT_CONTROLLER_NODES=3
    export VAGRANT_COMPUTE_NODES=3

`vagrant up` will cause all the VMs to be provisioned in the following
order:

1.  `admin` - the Crowbar admin server node.  After boot-up,
    `install-suse-cloud` will automatically run.  This takes quite a
    few minutes to complete, since it has to start several services.
    Once you see the next VM start to boot, you know it has completed
    installation, at which point you can visit the Crowbar web UI on
    [http://192.168.124.10:3000/](http://192.168.124.10:3000/) and
    watch the other nodes come online one by one.
2.  The controller nodes in numerical order: `controller1`, then
    `controller2` etc.  These will run the OpenStack infrastructure
    services, typically within a Pacemaker cluster.
3.  The compute nodes in numerical order: `compute1`, then `compute2`
    etc.

The first time you do this, it will automatically download the
required Vagrant boxes from https://vagrantcloud.com.  They are
approximately 2.6GB in total so please be patient.

It will take some additional time to provision each VM, since not only
does Vagrant need to copy a fresh virtual disk from the box for each
VM, but also on first boot the VMs will register against Crowbar and
then perform some orchestrated setup via Chef.

Alternatively, you can provision each VM individually, e.g.

    vagrant up admin
    vagrant up controller1

and so on.  Similarly, you can rebuilt an individual VM from scratch
in the normal Vagrant way, e.g.

    vagrant destroy compute1
    vagrant up compute1

## Connecting to the VMs

You can ssh via `vagrant`, e.g.:

    vagrant ssh admin
    vagrant ssh controller1 -- -l root

or directly to the admin node:

    ssh root@192.168.124.10

The root password is `vagrant`, as per
[convention](https://docs.vagrantup.com/v2/boxes/base.html).

## Setting up node aliases

By default, Crowbar and Chef name nodes according to the MAC address
of their primary interface.  This is not very human-friendly, so
Crowbar offers the option of assigning aliases (e.g. `controller1`,
`compute1` etc.) to nodes.  This Vagrant environment provides a simple
script to automate that: once you have booted your controller and
compute nodes, simply `ssh` to the admin server as per above, and run

    setup-node-aliases.sh

After you have done this, the admin server's DNS tables will update,
and you will be able to `ssh` conveniently from the admin node to
other nodes, e.g.

    ssh controller1

etc.

## Trying out SUSE Cloud

If you want to try out the new high availability functionality,
see the [HA guide](HA-GUIDE.md).

Otherwise, see the
[official SUSE Cloud product documentation](https://www.suse.com/documentation/suse-cloud4/).
