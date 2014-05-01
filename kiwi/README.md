# KIWI appliance for Crowbar admin node

[KIWI](https://en.opensuse.org/Portal:KIWI) is used to build a
`.vmdk` virtual disk, which will then be converted into a Vagrant box
by **FIXME**.

Here's [a quick introduction to KIWI](http://doc.opensuse.org/projects/kiwi/doc/#chap.introduction)
in case you need it.

## Building the KIWI image

### Installing KIWI

Unfortunately KIWI currently only runs on SUSE-based systems.  There
is definitely appetite to port it to other distributions but noone has
had the time to do so yet.  Another interesting option for the future
would be to rebuild this appliance using [Packer](http://www.packer.io/).
[Pull requests](https://help.github.com/articles/using-pull-requests)
are very welcome - just [fork this repository](https://github.com/fghaas/openstacksummit2014-atlanta/fork)!

1.  If you're on SLES11 SP3, add the openSUSE:Tools repository first
    to get the latest KIWI version.  For example:

        sudo zypper ar http://download.opensuse.org/repositories/openSUSE:/Tools/SLE_11_SP3/ openSUSE:Tools

    If you're on openSUSE 13.1, you should already have the Updates
    repository containing the latest KIWI version.

2.  Now install the required KIWI packages:

        sudo zypper in kiwi kiwi-desc-vmxboot

### Obtaining the required software

Building this appliance from scratch requires the following:

*   [SUSE Linux Enterprise Server (SLES) 11 SP3 installation media](https://download.suse.com/Download?buildid=Q_VbW21BiB4~) (you only need `SLES-11-SP3-DVD-x86_64-GM-DVD1.iso`; DVD2 is the source code)
*   [SUSE Linux Enterprise High Availability Extension (SLE HAE) 11 SP3](https://download.suse.com/Download?buildid=x_3696pRI0w~) (again, you only need `SLE-HA-11-SP3-x86_64-GM-CD1.iso`)
*   [SUSE Cloud 3 installation media](https://download.suse.com/Download?buildid=K3-lLTopFN4~) (again, you only need SUSE-CLOUD-3-x86_64-GM-DVD1.iso)
*   Package repositories containing updates for each of the above, to obtain the latest bugfixes and enhancements.
    *   Updates are available via subscriptions with a 60-day free evaluation; however all these products are Free Software, so of course you can still use them fully after 60 days - you just won't continue getting updates.
    *   The easiest way to obtain the updates is probably via the [Subscription Management Tool (SMT) 11 SP3](https://download.suse.com/Download?buildid=l8FuDkiYOg0~) ([more info on SMT here](https://www.suse.com/solutions/tools/smt.html)).
    *   Here are the links for free 60-day evaluations of [SLES](https://www.suse.com/products/server/eval.html), [SUSE Cloud](https://www.suse.com/products/suse-cloud/), and [SLE HAE](https://www.suse.com/products/highavailability/eval.html).

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

### Building the image

Now you can build the image by running:

    cd kiwi
    sudo KIWI_BUILD_TMP_DIR=/tmp/kiwi-build ./build-image.sh

The resulting `.vmdk` image will be in the `image/` directory.  The
build log is there too in case something went wrong and you need to
debug.

To speed up builds, the script automatically builds in tmpfs (RAM) if
it detects sufficient memory.  You may need to tweak the script to fit
your setup (patches welcomed!). The boot images are also automatically
cached in `/var/cache/kiwi/bootimage` to speed up subsequent
builds. You'll need to manually delete the files there to clear the
cache, but there's usually no need for that.
