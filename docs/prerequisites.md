# Prerequisites

## Hardware requirements

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
*   If using the KVM hypervisor, the capability to do nested
    virtualization will greatly aid performance of instances
    booted via OpenStack Compute (Nova).

## Software requirements

### Hypervisor

You will need one of the following hypervisors installed:

*   [VirtualBox](https://www.virtualbox.org/wiki/Downloads) >= 4.3.0
    (but the latest release is strongly recommended), or
*   [KVM](http://www.linux-kvm.org/page/Main_Page)

Here are some points to bear in mind when choosing a hypervisor:

*   KVM is only available on Linux.
*   [VirtualBox doesn't support nested virtualization.](https://www.virtualbox.org/ticket/4032)
    so OpenStack Compute nodes will need to use the QEMU software hypervisor
    instead, which will be quite a bit slower.
*   Some kernel developers are wary of the quality of the VirtualBox kernel modules.
*   Vagrant has native support for VirtualBox, which therefore tends to be
    slightly more robust than using the [`vagrant-libvirt` plugin](vagrant-libvirt.md).

#### Installing VirtualBox

On openSUSE, it is recommended to install from the
[OBS `Virtualization` project](https://build.opensuse.org/project/show/Virtualization).

For other OSs, here is the [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads).

#### Installing KVM

For KVM, you will also need [`libvirt`](http://libvirt.org/)
installed, including the development libraries, e.g. on openSUSE, do:

    zypper in libvirt libvirt-devel

## Vagrant

You will need [Vagrant](http://www.vagrantup.com/) >= 1.6.5 installed.
For all OSs [the upstream packages](https://www.vagrantup.com/downloads.html)
should work fine.

If on openSUSE, you can alternatively
[install from OBS](http://software.opensuse.org/package/rubygem-vagrant)
although you may well encounter issues, especially relating to
installation of plugins, and you will not be able to use the
`vagrant-login` (Vagrant Cloud) and `vagrant-share` plugins.

If using `libvirt`, please also see
[vagrant-libvirt.md](vagrant-libvirt.md).

### Vagrant boxes

You will need two boxes:

*   the `suse/cloud4-admin` box (currently only [available to SUSE
    employees](https://etherpad.nue.suse.com/p/cloud-vagrant)
    but hopefully will be published on https://vagrantcloud.com/suse
    soon; please [contact us](https://forums.suse.com/forumdisplay.php?65-SUSE-Cloud)
    if you need a copy urgently
*   a `suse/sles11sp3` box; again please [contact
    us](https://forums.suse.com/forumdisplay.php?65-SUSE-Cloud) regarding this
    as work is currently in flux

For each box there is a corresponding `.json` file containing metadata
about the box.

#### Installing the boxes

Note that you need to be in the directory containing the downloaded
boxes:

    # Adjust path as necessary:
    cd ~/Downloads

    # If you are using libvirt (adjust filename appropriately):
    vagrant box add cloud4-admin.x86_64-0.1.1.libvirt-Build4.18.json

    # or if you are using virtualbox:
    vagrant box add cloud4-admin.x86_64-0.1.1.virtualbox-Build4.18.json

and similarly for the `sles11sp3` box.

#### Updating an existing box

If a newer version of the box has been released and you want to update to it:

    # Adjust for VirtualBox if necessary
    vagrant box add --force cloud4-admin.x86_64-0.0.2.libvirt-Build2.2.json

**CAUTION!** If you are using libvirt, this is not enough to do
`vagrant box add --force` or even `vagrant box remove`; you will also
have to manually remove the old image from `/var/lib/libvirt/images` and
then do:

    virsh pool-refresh default

before adding the new version, due to
[this bug](https://github.com/pradels/vagrant-libvirt/issues/85#issuecomment-55419054).

### git repo

You will need a copy of this git repository downloaded.  You can
simply
[download a `.zip`](https://github.com/SUSE-Cloud/suse-cloud-vagrant/archive/master.zip),
or if you have `git` installed, clone it via `git`.  See the
[project page](../../..) for URLs to use with `git clone`.

N.B. On openSUSE, ensure that you have the `ca-certificates-mozilla`
package installed for successful cloning from github.
