# Automatically deploying a highly available OpenStack cloud

This demo shows how easy it is to use the Pacemaker barclamp to deploy
an OpenStack cloud which has highly available services.

## Prerequisites

First ensure you have
[the described prerequisites](../../docs/prerequisites.md).

You'll need at least 16GB RAM on the host for a full HA cloud,
since this demo defaults to using
[`vagrant/configs/2-controllers-1-compute.yaml`](../../vagrant/configs/2-controllers-1-compute.yaml)
in order to determine the number, size, and shape of the VMs
the [`Vagrantfile`](../../vagrant/Vagrantfile) will boot,
and
[`vagrant/provisioning/admin/HA-cloud.yaml`](../../vagrant/provisioning/admin/HA-cloud.yaml)
in order to determine how the Crowbar barclamps are applied.

However you may be able to get away with 8GB RAM by only setting up
the two clustered controller nodes running OpenStack services, and
skipping the compute node and deployment of Nova and Heat.  Obviously
this will prevent you from booting instances in the OpenStack cloud
via Nova, but you should still be able to test the HA functionality.

So if your host only has 8GB RAM, when following the instructions
below, **either** first copy and paste this into your terminal:

    export VAGRANT_CONFIG_FILE=configs/2-controllers-0-compute.yaml
    export PROPOSALS_YAML=/root/HA-cloud-no-compute.yaml

**or** use `build-8GB.sh` instead of `build.sh` which does exactly
the same but is easier to type.

N.B. The value for `VAGRANT_CONFIG_FILE` should either be an absolute
path, or relative to
[the directory containing `Vagrantfile`](../../vagrant), whereas the
value for `PROPOSALS_YAML` points to a path *inside* the admin server
VM, so should start with `/root/...`.

Whichever files you use, you can optionally tune the number, size, and
shape of the VMs being booted, by editing whichever file
`$VAGRANT_CONFIG_FILE` points to, and you can tune the barclamp
proposal parameters by editing whichever file `$PROPOSALS_YAML` points
to.

## Preparing the demo

**Read this whole section before running anything!**

If you are using Windows, please see [this page](Windows.md).

Then depending on your preferred hypervisor, simply run:

    ./build.sh virtualbox

or

    ./build.sh kvm

This will perform the following steps:

*   Use Vagrant to build one Crowbar admin node, two controller nodes,
    and a compute node, including an extra DRBD disk on each controller
    and a shared SBD disk.
*   Run [`/root/bin/setup-node-aliases.sh`](../../vagrant/provisioning/admin/setup-node-aliases.sh)
    to set aliases in Crowbar for the controller and compute nodes
*   Create and apply a standard set of Crowbar proposals as described
    in detail below.

If you prefer to perform any of these steps manually as part of the
demo (e.g. creating the proposals and/or preparing the cloud for the
demo), you can easily comment those steps out of `build.sh`.

N.B. All steps run by `./build.sh` are idempotent, so you can safely
run it as many times as you need.

## Deployment of a highly available OpenStack cloud

This section describes how to manually set up the barclamp proposals.
By default `./build.sh` will automatically do this for you, but if you
prefer to do it manually, simply comment out the lines which call
`crowbar batch` near the end of the script, and then follow the
instructions in this page:

* [Guide to manual application of barclamp proposals for an HA cloud](manual-barclamps.md)

If you want, you can even mix'n'match the manual and automatic
approaches, by adding `--include` / `--exclude` options to the
invocation of `crowbar batch` filtering which proposals get applied,
and/or by editing
[`/root/HA-cloud.yaml`](../../vagrant/provisioning/admin/HA-cloud.yaml)
on the Crowbar admin node, and commenting out certain proposals.
However, you should be aware that the proposals need to be applied in
the order given, regardless of whether they are applied manually or
automatically.

### Watching the cluster being built

As soon as the Pacemaker barclamp's `cluster1` proposal has been
applied (i.e. showing a green bubble icon in the Crowbar web UI),
you can connect to the [Hawk web UI](https://192.168.124.81:7630)
and watch as Chef automatically adds new resources to the cluster.

If you're interested in a more internal glimpse of how Crowbar is
orchestrating Chef behind the scenes to configure resources across the
nodes,
[connect to the `admin` VM](../../docs/HOWTO.md#connecting-to-the-vms)
and then type:

    tail -f /var/log/crowbar/chef-client/*.log

## Playing with High Availability

Please see the following pages:

*   [testing failover](cluster-failover.md) - how to do nasty
    things to your OpenStack infrastructure cluster!
*   [cluster recovery](cluster-recovery.md) - a quick guide
    for how to recover your cluster to a healthy state after
    doing nasty things to it :-)

## Performing Vagrant operations

If you want to use `vagrant` to control the VMs, e.g. `vagrant halt` /
`destroy`, then first `cd` to the `vagrant/` subdirectory of the git
repository:

    cd ../../vagrant

If you are using `libvirt`, you will probably need to prefix `vagrant`
with `bundle exec` every time you run it, e.g.:

    bundle exec vagrant status
    bundle exec vagrant halt compute1

See [the `vagrant-libvirt` page](../../docs/vagrant-libvirt.md) for
more information.
