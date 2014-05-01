# KIWI appliance for Crowbar admin node

[KIWI](https://en.opensuse.org/Portal:KIWI) is used to build a
`.qcow2` virtual disk, which will then be converted into a Vagrant box
by **FIXME**.

Here's [a quick introduction to KIWI](http://doc.opensuse.org/projects/kiwi/doc/#chap.introduction)
in case you need it.

## Building the KIWI image

### Installing KIWI

Unfortunately KIWI currently only runs on SUSE-based systems.  There
is definitely appetite to port it to other distributions but noone has
had the time to do so yet.

1.  If you're on SLES11 SP3, add the openSUSE:Tools repository first
    to get the latest KIWI version.  For example:

        sudo zypper ar http://download.opensuse.org/repositories/openSUSE:/Tools/SLE_11_SP3/ openSUSE:Tools

    If you're on openSUSE 13.1, you should already have the Updates
    repository containing the latest KIWI version.

2.  Now install the required KIWI packages:

        sudo zypper in kiwi kiwi-desc-vmxboot

### Building the image

Now you can build the image by running:

    sudo ./create_appliance.sh

The resulting `.qcow2` image will be in the `image/` directory.  The
build log is there too in case something went wrong and you need to
debug.

To speed up builds, the script automatically builds in tmpfs (RAM) if
it detects sufficient memory.  You may need to tweak the script to fit
your setup (patches welcomed!). The boot images are also automatically
cached in `/var/cache/kiwi/bootimage` to speed up subsequent
builds. You'll need to manually delete the files there to clear the
cache, but there's usually no need for that.
