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

## Vagrant fails during the creation of my controllers

If the Vagrant build fails with the following error:

    Defined interface to use (eth1) does not seem to be on the admin network.
    Is DHCP used for it?

Then VirtualBox has a host-only network conflicting with the one from
Vagrant. Please refer to the **Vagrant `virtualbox` provider** section
in [the prerequisites](prerequisites.md) to fix this, and then restart
the Vagrant build.

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

## `crowbar batch` fails on start

If `crowbar batch` fails with an error like:

    /opt/dell/bin/barclamp_lib.rb:536:in `eval': (<unknown>): found character that cannot start any token while scanning for the next token at line 19 column 11 (Psych::SyntaxError)
            from /usr/lib64/ruby/2.1.0/psych.rb:370:in `parse_stream'
            from /usr/lib64/ruby/2.1.0/psych.rb:318:in `parse'
            from /usr/lib64/ruby/2.1.0/psych.rb:245:in `load'
            from /opt/dell/bin/crowbar_batch:100:in `build'
            from (eval):1:in `run_sub_command'
            from /opt/dell/bin/barclamp_lib.rb:536:in `eval'
            from /opt/dell/bin/barclamp_lib.rb:536:in `run_sub_command'
            from /opt/dell/bin/barclamp_lib.rb:540:in `run_command'
            from /opt/dell/bin/crowbar_batch:553:in `main'
            from /opt/dell/bin/crowbar_batch:556:in `<main>'

This is most likely happening because the aliases for the nodes were not
created. Simply run the `setup-node-aliases.sh` command on the node
`admin` and then run `crowbar batch` again.
