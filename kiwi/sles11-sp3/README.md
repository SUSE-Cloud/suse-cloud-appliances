# KIWI appliance for Crowbar client nodes

**Please ensure that you have first read the
[general information on KIWI](../README.md).**

The KIWI appliance definition in this subdirectory is for building a a
simple SLES11 SP3 JeOS image which will form the basis for the cloud
controller node(s), compute node(s), and storage node(s).  Once each
of these nodes boots up, it will register against the Crowbar admin
node, and subsequently execute further provisioning steps as
instructed by the admin node.

## Building the KIWI image

First [ensure that you have KIWI installed](../README.md).

### Obtaining the required software

Building this appliance from scratch requires the following:

*   [SUSE Linux Enterprise Server (SLES) 11 SP3 installation media](https://download.suse.com/Download?buildid=Q_VbW21BiB4~) (you only need `SLES-11-SP3-DVD-x86_64-GM-DVD1.iso`; DVD2 is the source code)
*   [VirtualBox Guest Additions `.iso`](http://download.virtualbox.org/virtualbox/).  Mount the `.iso` on the image-building host, and copy the `VBoxLinuxAdditions.run` file into `source/root/tmp` under this directory.

### Setting up the mountpoints

The appliance config currently assumes the following mountpoints are
set up on the system which will build the image:

*   SLES11 SP3 installation media at `/mnt/sles-11-sp3`

It also assumes that the update channels will have been mirrored to
the following locations:

*   `/data/install/mirrors/SLES11-SP3-Updates/sle-11-x86_64`
*   `/data/install/mirrors/SLE-11-SP3-SDK/sle-11-x86_64`
*   `/data/install/mirrors/SLE-11-SP3-SDK-Updates/sle-11-x86_64`

### Building the image and cleaning up

Now you can build the image by running:

    cd kiwi
    sudo KIWI_BUILD_TMP_DIR=/tmp/kiwi-build ./build-image.sh

The resulting `.vmdk` image will be in the `image/` directory.  The
build log is there too on successful build.  If something went wrong
then everything is left in `/tmp/kiwi-build`, and you will need to
clean that directory up in order to reclaim the disk space.

To speed up builds, the script automatically builds in tmpfs (RAM) if
it detects sufficient memory.  If the build succeeds it will
automatically `umount` the RAM disk; however on any type of failure
you will need to manually `umount` it in order to reclaim a huge chunk
of RAM!

The boot images are also automatically cached in
`/var/cache/kiwi/bootimage` to speed up subsequent builds. You'll need
to manually delete the files there to clear the cache, but there's
usually no need for that.

## Building and installing the Vagrant box

Once you have the `.vmdk` built, do:

    cd ../../vagrant/sles11-sp3

and follow the instructions in
[the corresponding README](../../vagrant/sles11-sp3/README.md).
