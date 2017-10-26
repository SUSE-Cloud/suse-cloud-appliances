# KIWI appliance for Crowbar admin node

**Please ensure that you have first read the
[general information on KIWI](../README.md).**

The KIWI appliance definition in this subdirectory is for building a
Crowbar admin node on top of SLES12 SP2.  Once provisioned, this node
will be responsible for automatically provisioning the rest of the
OpenStack cloud (in a highly available configuration, if requested by
the cloud operator).

## Building the KIWI image

First [ensure that you have KIWI installed](../README.md).

### Obtaining the required software

There are two ways to build this appliance from scratch:

1.  The slow (but more "complete" and fully supported) way, which requires the following:
    *   [SUSE Linux Enterprise Server (SLES) 12 SP2 installation media](https://download.suse.com/Download?buildid=qb71v1YjQjI~) (you only need `SLES-12-SP2-DVD-x86_64-GM-DVD1.iso`; DVD2 is the source code)
    *   [SUSE Linux Enterprise High Availability Extension (SLE HA) 12 SP2](https://download.suse.com/Download?buildid=HEl-kKOjqS0~) (again, you only need `SLE-12-SP2-HA-DVD-x86_64-GM-CD1.iso`)
    *   [SUSE OpenStack Cloud 7 installation media](https://download.suse.com/Download?buildid=xY_5_IAEbxI~) (again, you only need SUSE-OPENSTACK-CLOUD-7-x86_64-GM-DVD1.iso)
    *   Package repositories containing updates for each of the above, to obtain the latest bugfixes and enhancements.
        *   Updates are available via subscriptions with a 60-day free evaluation; however all these products are Free Software, so of course you can still use them fully after 60 days - you just won't continue getting updates.
        *   The easiest way to obtain the updates is probably via the Subscription Management Tool (SMT) ([more info on SMT here](https://www.suse.com/solutions/tools/smt.html)).
        *   Here are the links for free 60-day evaluations of [SLES](https://www.suse.com/products/server/eval.html), [SUSE OpenStack Cloud](https://www.suse.com/products/suse-cloud/), and [SLE HA](https://www.suse.com/products/highavailability/eval.html).

    This way takes quite some time (and about 15GB of spare disk) to
    set up, because you need to first build an SMT environment, and
    then mirror all the packages (including updates) for SLES 12 SP3,
    SLE 12 HA SP2, SLE 12 SDK SP2, and SUSE OpenStack Cloud 7.

2.  The quick way (which is currently only supported on a best effort
    basis) drastically reduces the number of dependencies by relying
    on:

    *   a specially constructed `SUSE-OPENSTACK-CLOUD-7-DEPS` `.iso`
        which contains the minimal set of packages which SUSE OpenStack
        Cloud 7 requires from SLES 12 SP2 and SLE 12 HA SP2 including the
        latest updates, and
    *   an `.iso` of the latest (unreleased) development build of
        SUSE OpenStack Cloud, which contains the latest updates.

    These are currently provided on demand only.

Both ways also require:

*   [SLE 12 SDK SP2](https://download.suse.com/Download?buildid=g3e7P21X6Lw~) (although
    if you are willing to tolerate a slightly ugly `grub` boot menu then you can avoid
    this requirement by commenting out the SDK packages and repositories in
    [`source/config.xml.tmpl`](source/config.xml.tmpl)), and
*   [VirtualBox Guest Additions `.iso`](http://download.virtualbox.org/virtualbox/).
    Mount the `.iso` on the image-building host, and copy the
    `VBoxLinuxAdditions.run` file into `source/root/tmp` under this
    directory.

### Setting up the mountpoints

The appliance [`config.xml` template](source/config.xml.tmpl)
currently assumes certain mountpoints are set up on the system which
will build the image.  For the slow way:

*   `/mnt/sles-12-sp2`: SLES 12 SP2 installation media
*   `/mnt/suse-cloud-7`: SUSE OpenStack Cloud 7 installation media

For the quick way:

*   `/mnt/sles-12-sp2`: the `SUSE-OPENSTACK-CLOUD-7-DEPS` `.iso`
*   `/mnt/suse-cloud-7`: the `.iso` of the latest development build of SUSE OpenStack Cloud
*   `/mnt/sle-12-sdk-sp2`: SLE 12 SDK SP2 installation media (although
    this can be omitted as per above.  FIXME: this also currently requires
    editing the [`config.xml` template](source/config.xml.tmpl).)

It also assumes that the update channels will have been mirrored to
certain locations.  For the slow way:

*   `/data/install/mirrors/SLE-12-SP2-SDK/sle-12-x86_64`
*   `/data/install/mirrors/SLE12-HA-SP2-Pool/sle-12-x86_64`
*   `/data/install/mirrors/SLE12-HA-SP2-Updates/sle-12-x86_64`
*   `/data/install/mirrors/SUSE-Cloud-7-Pool/sle-12-x86_64`
*   `/data/install/mirrors/SUSE-Cloud-7-Updates/sle-12-x86_64`

For the quick way:

*   `/data/install/mirrors/SLE-12-SP2-SDK/sle-12-x86_64`

(FIXME: this currently requires editing the
[`config.xml` template](source/config.xml.tmpl).)

You can optionally specify an alternate location to
`/data/install/mirrors` by ading an extra `sudo` parameter before
`./build-image.sh`., e.g.

    sudo MIRRORS='/srv/www/htdocs/repo/$RCE' ./build-image.sh

might be a typical case if you are mirroring via SMT.

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

To speed up builds, the script automatically builds on a dedicated
`tmpfs` filesystem (i.e. in RAM) if it detects sufficient memory.  If
the build succeeds it will automatically `umount` the RAM disk;
however on any type of failure you will need to manually `umount` it
in order to reclaim a huge chunk of RAM!  You can disable use of
`tmpfs` by including `NO_TMPFS=y` as an extra `sudo` parameter before
`./build-image.sh`.

**BEWARE!** There is
[an obscure kernel bug](https://bugzilla.novell.com/show_bug.cgi?id=895204)
which can cause processes to latch onto mounts created by `kiwi`
within the chroot, preventing the chroot from being properly cleaned
up until those processes are killed.  See the bug for how to detect
these guilty processes.  If you are using `tmpfs`, this is
particularly serious because the kernel will not free the RAM used by
the filesystem until the processes are killed.  **It is very easy to
kill a system due to extreme low memory after a few kiwi builds if you
do not work around this bug after each build.**

The boot images are also automatically cached in
`/var/cache/kiwi/bootimage` to speed up subsequent builds.  You'll
need to manually delete the files there to clear the cache, but
there's usually no need for that.

## Building and installing the Vagrant box

Once you have the `.vmdk` built, do:

    cd ../../vagrant/cloud-admin

and follow the instructions in
[the corresponding README](../../vagrant/cloud-admin/README.md).
