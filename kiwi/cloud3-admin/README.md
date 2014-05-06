# KIWI appliance for Crowbar admin node

**Please ensure that you have first read the
[general information on KIWI](../README.md).**

The KIWI appliance definition in this subdirectory is for building a
Crowbar admin node on top of SLES11 SP3.  Once provisioned, this node
will be responsible for automatically provisioning the rest of the
OpenStack cloud (in a highly available configuration, if requested by
the cloud operator).

## Building the KIWI image

First [ensure that you have KIWI installed](../README.md).

### Obtaining the required software

Building this appliance from scratch requires the following:

*   [SUSE Linux Enterprise Server (SLES) 11 SP3 installation media](https://download.suse.com/Download?buildid=Q_VbW21BiB4~) (you only need `SLES-11-SP3-DVD-x86_64-GM-DVD1.iso`; DVD2 is the source code)
*   [SUSE Linux Enterprise High Availability Extension (SLE HAE) 11 SP3](https://download.suse.com/Download?buildid=x_3696pRI0w~) (again, you only need `SLE-HA-11-SP3-x86_64-GM-CD1.iso`)
*   [SUSE Cloud 3 installation media](https://download.suse.com/Download?buildid=K3-lLTopFN4~) (again, you only need SUSE-CLOUD-3-x86_64-GM-DVD1.iso)
*   Package repositories containing updates for each of the above, to obtain the latest bugfixes and enhancements.
    *   Updates are available via subscriptions with a 60-day free evaluation; however all these products are Free Software, so of course you can still use them fully after 60 days - you just won't continue getting updates.
    *   The easiest way to obtain the updates is probably via the [Subscription Management Tool (SMT) 11 SP3](https://download.suse.com/Download?buildid=l8FuDkiYOg0~) ([more info on SMT here](https://www.suse.com/solutions/tools/smt.html)).
    *   Here are the links for free 60-day evaluations of [SLES](https://www.suse.com/products/server/eval.html), [SUSE Cloud](https://www.suse.com/products/suse-cloud/), and [SLE HAE](https://www.suse.com/products/highavailability/eval.html).
*   [VirtualBox Guest Additions `.iso`](http://download.virtualbox.org/virtualbox/).  Mount the `.iso` on the image-building host, and copy the `VBoxLinuxAdditions.run` file into `source/root/tmp` under this directory.

### Setting up the mountpoints

The appliance config currently assumes the following mountpoints are
set up on the system which will build the image:

*   SLES11 SP3 installation media at `/mnt/sles-11-sp3`
*   SUSE Cloud 3 installation media `/mnt/suse-cloud-3`

It also assumes that the update channels will have been mirrored to
the following locations:

*   `/data/install/mirrors/SLES11-SP3-Updates/sle-11-x86_64`
*   `/data/install/mirrors/SLE-11-SP3-SDK/sle-11-x86_64`
*   `/data/install/mirrors/SLE-11-SP3-SDK-Updates/sle-11-x86_64`
*   `/data/install/mirrors/SUSE-Cloud-3.0-Pool/sle-11-x86_64`
*   `/data/install/mirrors/SUSE-Cloud-3.0-Updates/sle-11-x86_64`

Finally, if you want the appliance to contain the necessary media and
repositories embedded under `/srv/tftpboot` (recommended, since this
is required in order that the Crowbar admin node can serve packages to
the other nodes), then you can bind-mount those repositories into the
kiwi overlay filesystem by running the following script prior to
building the KIWI image:

    sudo ./mount-repos.sh

### Building the image and cleaning up

Now you can build the image by running:

    cd kiwi
    sudo KIWI_BUILD_TMP_DIR=/tmp/kiwi-build ./build-image.sh

The resulting `.vmdk` image will be in the `image/` directory.  The
build log is there too on successful build.  If something went wrong
then everything is left in `/tmp/kiwi-build`, and you will need to
clean that directory up in order to reclaim the disk space.

You can `umount` the overlay bind-mounts as follows:

    sudo ./umount-repos.sh

To speed up builds, the script automatically builds in tmpfs (RAM) if
it detects sufficient memory.  If the build succeeds it will
automatically `umount` the RAM disk; however on any type of failure
you will need to manually `umount` it in order to reclaim a huge chunk
of RAM!

The boot images are also automatically cached in
`/var/cache/kiwi/bootimage` to speed up subsequent builds.  You'll
need to manually delete the files there to clear the cache, but
there's usually no need for that.

## Building and installing the Vagrant box

Once you have the `.vmdk` built, do:

    cd ../../vagrant/cloud3-admin

and follow the instructions in
[the corresponding README](../../vagrant/cloud3-admin/README.md).
