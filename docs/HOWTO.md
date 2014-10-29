# How to automatically deploy SUSE Cloud via Vagrant

## Prerequisites

Please see the [prerequisites page](prerequisites.md) for information
on hardware requirements and how to set up Vagrant to work with your
hypervisor.

## SUSE Cloud installation

N.B. The following steps describe semi-automated booting of the cloud
infrastructure via Vagrant.  Another more fully automated option is
to use one of the [pre-canned demos](../demos/README.md).

*   Depending on what cloud configuration you desire, either use Vagrant
    to sequentially provision all four VMs from the default configuration
    (1 admin + 2 controllers + 1 compute node) in one go:

        cd vagrant
        vagrant up

    or keep reading to find out how to choose which VMs to
    provision.

There is always exactly one admin server node.  The quantity, shape,
and size of all nodes are determined by a YAML config file.  The
default is
[`2-controllers-1-compute.yaml`](../vagrant/configs/2-controllers-1-compute.yaml)
but there are other examples in
[the same directory](../vagrant/configs/).

You can change the number of controller nodes and compute notes from
the defaults of 2 and 1 respectively by editing this file or by
pointing the `Vagrantfile` at an alternative config file:

    export VAGRANT_CONFIG_FILE=/path/to/other/vagrant.yaml

`vagrant up --no-parallel` will cause all the VMs to be provisioned in
the order listed in the YAML config file.  Typically this is:

1.  `admin` - the Crowbar admin server node.  After boot-up,
    `install-suse-cloud` will automatically run.  This takes quite a
    few minutes to complete, since it has to start several services.
    Once you see the next VM start to boot, you know it has completed
    installation, at which point you can visit
    [the Crowbar web UI](http://192.168.124.10:3000/) and watch the
    other nodes come online one by one.
2.  The controller node(s) in numerical order: `controller1`, then
    `controller2` etc.  These will run the OpenStack infrastructure
    services, typically within a Pacemaker cluster.
3.  The compute nodes in numerical order: `compute1`, then `compute2`
    etc.

It will take a few minutes to provision each VM, since not only does
Vagrant need to copy a fresh virtual disk from the box for each VM,
but also on first boot the VMs will register against Crowbar and then
perform some orchestrated setup via Chef.

Alternatively, you can provision each VM individually, e.g.

    vagrant up admin
    vagrant up controller1

and so on.  Similarly, you can rebuild an individual VM from scratch
in the normal Vagrant way, e.g.

    vagrant destroy compute1
    vagrant up compute1

or the entire cloud in one go:

    vagrant destroy
    vagrant up --no-parallel

**CAUTION!** If you are using libvirt, please see [this page about
usage `vagrant-libvirt`](vagrant-libvirt.md) for known pitfalls.

## Connecting to the VMs

Of course you can log in on the VM consoles, via the hypervisor's
GUI.

You can also ssh via `vagrant`, e.g.:

    vagrant ssh admin
    vagrant ssh controller1 -- -l root

or directly to the admin node:

    ssh root@192.168.124.10

The root password is `vagrant`, as per
[convention](https://docs.vagrantup.com/v2/boxes/base.html).

## Setting up node aliases

By default, Crowbar and Chef name nodes according to the MAC address
of their primary interface.  This is not very human-friendly, so
Crowbar offers the option of assigning aliases (e.g. `controller1`,
`compute1` etc.) to nodes.  This Vagrant environment provides a simple
script to automate that: once you have booted your controller and
compute nodes, simply `ssh` to the admin server as per above, and run:

    setup-node-aliases.sh

After you have done this, the admin server's DNS tables will update,
and you will be able to `ssh` conveniently from the admin node to
other nodes, e.g.

    ssh controller1

etc.

N.B. The `./build.sh` demo scripts take care of this automatically.

## Setting up node/role shell variables (OPTIONAL)

If you want to poke around behind the scenes and see how Crowbar uses
Chef, you can use the `knife` command on the admin server.  However it
can quickly get tedious figuring out the correct node or role name
corresponding to say, `controller2`.  Therefore the `Vagrantfile`
automatically installs a handy
[`node-sh-vars` script](../vagrant/provisioning/admin/node-sh-vars)
which can set convenient shell variables for the node and role names.
Once you have booted your controller and compute nodes, simply `ssh`
to the admin server as per above, and run:

    node-sh-vars > /tmp/.crowbar-nodes-roles.cache
    source /tmp/.crowbar-nodes-roles.cache

Now you can easily look at Chef nodes via `knife`, e.g.

    knife node show $controller1
    knife node list

and similarly for roles:

    knife role show $controller1r
    knife role list

The `Vagrantfile` also sets up `.bash_profile` so that
`/tmp/.crowbar-nodes-roles.cache` is automatically `source`d
on login.

N.B. The `./build.sh` demo scripts take care of this automatically.

## Trying out SUSE Cloud

*   See the provided resources for
    [automatically preparing and presenting demos](../demos/README.md) of
    functionality within SUSE Cloud.

Also see the
[official SUSE Cloud product documentation](https://www.suse.com/documentation/suse-cloud4/).
