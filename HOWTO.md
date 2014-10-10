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
*   either [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >=
    4.2 (4.3 recommended; older may work but untested), or
    [`libvirt`](http://libvirt.org/) installed, including the development
    libraries, e.g.:

        zypper in libvirt libvirt-devel

*   [Vagrant](http://www.vagrantup.com/) >= 1.5.x installed (latest 1.6.x recommended)
*   if using `libvirt`,
    [`vagrant-libvirt` plugin](https://github.com/pradels/vagrant-libvirt) >= 0.20.0
    installed, e.g.:

        vagrant plugin install vagrant-libvirt

*   a small bootable VM image ([CirrOS image is recommended](http://download.cirros-cloud.net/))
*   this git repository
*   the `suse/cloud4-admin` box (currently only [available to SUSE
    employees](https://etherpad.nue.suse.com/p/cloud-vagrant)
    but hopefully will be published on https://vagrantcloud.com/suse
    soon; please [contact us](https://forums.suse.com/forumdisplay.php?65-SUSE-Cloud)
    if you need a copy urgently
*   a `suse/sles11-sp3` box; again please [contact
    us](https://forums.suse.com/forumdisplay.php?65-SUSE-Cloud) regarding this
    as work is currently in flux
*   an internet connection, or if you want to do this offline, you need
    to pre-download the two Vagrant boxes before you disconnect:

        vagrant box add suse/cloud4-admin
        vagrant box add suse/sles11-sp3

## SUSE Cloud installation

*   If using VirtualBox:
    *   Start the GUI
    *   *File* → *Preferences* → *Network* then ensure you have:
        *   a single NAT network (in VirtualBox 4.2 this is hardcoded so
            don’t worry about it)
        *   a host-only network, named `vboxnet0`, with IP `192.168.124.1`
            and **DHCP disabled**.
*   Depending on what cloud configuration you desire, either use Vagrant
    to sequentially provision four VMs in one go:

        cd vagrant
        vagrant up

    or keep reading to find out how to choose individual VMs to
    provision.

If you do the above, the VMs will be provisioned in the following
order:

*   `admin` - the Crowbar admin node.  After boot-up, `install-suse-cloud`
    will automatically run.  This takes quite a few minutes to complete,
    since it has to start several services.  Once you see the next VM
    start to boot, you know it has completed installation, at which point
    you can visit the Crowbar web UI on
    [http://192.168.124.10:3000/](http://192.168.124.10:3000/) and watch
    the other nodes come online one by one.
*   `controller1` - the first of the two controller nodes which will run
    the OpenStack infrastructure services within a Pacemaker cluster
*   `controller2`
*   `compute1` - the compute node

The first time you do this, it will automatically download the
required Vagrant boxes from https://vagrantcloud.com.  They are
approximately 5GB in total so please be patient.

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

## Trying out SUSE Cloud

If you want to try out the new high availability functionality,
see the [HA guide](HA-guide.md).

Otherwise, see the
[official SUSE Cloud product documentation](https://www.suse.com/documentation/suse-cloud4/).
