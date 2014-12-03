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

## Vagrant fails to create a host-only network on VirtualBox

    Progress state: NS_ERROR_FAILURE
    VBoxManage: error: Failed to create the host-only adapter
    VBoxManage: error: VBoxNetAdpCtl: Error while adding new interface: VBoxNetAdpCtl: ioctl failed for /dev/vboxnetctl: Inappropriate ioctl for devic
    VBoxManage: error: Details: code NS_ERROR_FAILURE (0x80004005), component HostNetworkInterface, interface IHostNetworkInterface
    VBoxManage: error: Context: "int handleCreate(HandlerArg*, int, int*)" at line 66 of file VBoxManageHostonly.cpp

Firstly make sure you don't have another network (e.g. bridge
interface) configured to use 192.168.124.0/24.  If not, try
restarting VirtualBox services.  On MacOS X:

    sudo /Library/StartupItems/VirtualBox/VirtualBox restart

On SUSE / Red Hat:

    service vboxdrv restart

## Vagrant NetworkCollision on VirtualBox

    INFO interface: Machine: error-exit ["Vagrant::Errors::NetworkCollision", "The specified host network collides with a non-hostonly network!\nThis will cause your specified IP    to be inaccessible. Please change\nthe IP or name of your host only network so that it no longer matches that of\na bridged or non-hostonly network."]

Make sure you have only one host-only network configured to use 192.168.124.0/24 . If you have libvirt running, check that no libvirt network using 192.168.124.0/24 .

## Vagrant fails ssh error on VirtualBox

    The following SSH command responded with a non-zero exit status.

If you are using the vagrant cloud box, make sure you are on the vagrantcloud branch.

## Vagrant can't ssh, I modified the network configuration in the yaml files

The IP ranges are not supposed to be modified. Please revert the change and try again.



