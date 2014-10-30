# Prerequisites

Here's the checklist; click on each item for more details:

*   [Hardware requirements](#hardware-requirements)
*   [Hypervisor](#hypervisor)
*   [Vagrant](#vagrant) (medium-sized download)
*   [Vagrant boxes](#vagrant-boxes) (**big downloads!**)
*   [This git repository](#git-repository) (small download)

***Please do not rely on conference or hotel wifi to download these
files!***

## Hardware requirements

*   x86_64 machine with
    [hardware virtualization capability](http://en.wikipedia.org/wiki/X86_virtualization)
    (Intel VT-x or AMD-V) enabled in the BIOS, and at least ~16GB
    spare disk and 3GB RAM, but:
    *   You should have at least 16GB RAM for building a full HA cloud.
    *   If you only have 8GB and want to build a two-node HA cluster
        for the control plane then you will not have enough RAM for a
        compute node in order to provision a VM instance in the cloud.
        However this is still plenty interesting enough to be worth
        attempting!
    *   If you have 6GB you could opt for a single controller node in a
        non-HA configuration.
    *   If you only have 3 or 4GB, you will be able to run the Crowbar
        admin node via `vagrant up admin` but nothing else.  This is
        not very useful but at least lets you poke around [the Crowbar
        UI](http://192.168.124.10:3000).
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

*   KVM is only available on Linux, so if you're on a Mac or Windows,
    you have to use VirtualBox.
*   Vagrant has native support for VirtualBox, which therefore tends to be
    slightly more robust than using the [`vagrant-libvirt` plugin](vagrant-libvirt.md).
*   [VirtualBox doesn't support nested virtualization.](https://www.virtualbox.org/ticket/4032)
    so OpenStack Compute nodes will need to use the QEMU software hypervisor
    instead, which will be quite a bit slower.
*   KVM can harness
    [Kernel SamePage Merging (KSM)](http://en.wikipedia.org/wiki/Kernel_SamePage_Merging_(KSM))
    for more efficient use of RAM, sharing memory pages not only between
    Vagrant (i.e. Crowbar) VMs, but also between cloud instances booted via
    OpenStack Compute (nova).
*   Some kernel developers are critical of the quality of the VirtualBox
    kernel modules.

#### Installing VirtualBox

On SUSE systems, it is recommended to install from the
[OBS `Virtualization` project](https://build.opensuse.org/project/show/Virtualization).
The simplest way to do this is probably via 1-click install:

*    Visit http://software.opensuse.org/package/virtualbox
*    Select "Show other versions"
*    Select "Show unstable packages"
*    Select "1 Click Install" at the end of the `Virtualization` line
*    Download and open the resulting `.ymp` file, and follow the instructions.

For other OSs, you can
[download from virtualbox.org](https://www.virtualbox.org/wiki/Downloads).

On Linux systems:

*   Once installed, make sure that the VirtualBox kernel
    modules are loaded and that the services (`vboxdrv`) were started.
*   Make sure that the user account you are going to use for
    running VirtualBox and Vagrant (non-`root` recommended) has
    been added to the `vboxusers` group.
*   Make sure that your command shell already has access to the
    `vboxusers` group.  You can check by running the `groups`
    command; `vboxusers` should be included in the output.  If
    not, either run `newgrp vboxusers` or log out and in again.

(The `build.sh` scripts in the [pre-canned demos](../demos/)
automatically check all this for you.)

#### Installing KVM

For KVM, you will also need [`libvirt`](http://libvirt.org/)
installed, including the development libraries, e.g. on openSUSE, do:

    zypper in libvirt libvirt-devel

### Vagrant

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

#### Vagrant boxes

You will need two boxes, which are fairly big downloads:

*   `suse/cloud4-admin` (~2.4GB)
*   `suse/sles11sp3` (~550MB)

They are available from Vagrant Cloud by typing the following in the
same user account from which you will use them:

    vagrant box add suse/cloud4-admin
    vagrant box add suse/sles11sp3

#### Updating an existing box

Please see https://docs.vagrantup.com/v2/boxes/versioning.html

**CAUTION!** If you are using `vagrant-libvirt`, there is a known
pitfall with updating boxes; please see
[this caveat](vagrant-libvirt.md#updating-an-existing-box).

### git repository

You will need a copy of this git repository downloaded.  You can
simply
[download a `.zip`](https://github.com/SUSE-Cloud/suse-cloud-vagrant/archive/master.zip),
or if you have `git` installed, clone it via `git`.  See the
[project page](../../..) for URLs to use with `git clone`.

N.B. On openSUSE, ensure that you have the `ca-certificates-mozilla`
package installed for successful cloning from github.
