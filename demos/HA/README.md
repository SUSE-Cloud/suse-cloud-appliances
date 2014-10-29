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
`crowbar batch` near the end of the script, and then follow the below
instructions.

If you want, you can even mix'n'match the manual and automatic
approaches, by adding `--include` / `--exclude` options to the
invocation of `crowbar batch` filtering which proposals get applied,
and/or by editing
[`/root/HA-cloud.yaml`](../../vagrant/provisioning/admin/HA-cloud.yaml)
on the Crowbar admin node, and commenting out certain proposals.
However, you should be aware that the proposals need to be applied in
the order given, regardless of whether they are applied manually or
automatically.

### Deploy a Pacemaker cluster

*   Go to tab *Barclamps* → *OpenStack* and click on *Edit* for *Pacemaker*
*   Change `proposal_1` to `cluster1` and click *Create*
*   Scroll down to *Deployment*, and drag the `controller1` and `controller2`
    nodes to both roles (**pacemaker-cluster-member** and **hawk-server**)
*   Scroll back up and change the following options:
    *   *STONITH* section:
        *   Change *Configuration mode for STONITH* to
            **STONITH - Configured with STONITH Block Devices (SBD)**
        *   Enter `/dev/sdc` for both nodes under **Block devices for node**
    *   *DRBD* section:
        *   Change *Prepare cluster for DRBD* to `true`
            (`controller1` and `controller2` should have free disk to claim)
    *   *Pacemaker GUI* section:
        *   Change *Setup non-web GUI (hb_gui)* to `true`
*   Click on *Apply* to deploy Pacemaker

**Hint:** You can follow the deployment by typing
`tail -f /var/log/crowbar/chef_client/*` on the admin node.

### Deploy Barclamps / OpenStack / Database

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for Database
*   Under *Deployment*, remove the node that is assigned to the
    **database-server** role, and drag `cluster1` to the **database-server** role
*   Change the following options:
    * *High Availability* section:
        * Change *Storage mode* to **DRBD**
        * Change *Size to Allocate for DRBD Device* to **1**
*   Click on *Apply* to deploy the database

### Deploy Barclamps / OpenStack / RabbitMQ

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for RabbitMQ
*   Under *Deployment*, remove the node that is assigned to the
    **rabbitmq-server** role, and drag `cluster1` to the
    **rabbitmq-server** role
*   Change the following options:
    * *High Availability* section:
        * Change *Storage mode* to **DRBD**
        * Change *Size to Allocate for DRBD Device* to **1**
*   Click on *Apply* to deploy RabbitMQ

### Deploy Barclamps / OpenStack / Keystone

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for Keystone
*   Do not change any option
*   Under *Deployment*, remove the node that is assigned to the
    **keystone-server** role, and drag `cluster1` to the **keystone-server** role
*   Click on *Apply* to deploy Keystone

### Deploy Barclamps / OpenStack / Glance

**N.B.!** To simplify the HA setup of Glance for the workshop, a NFS
export has been automatically setup on the admin node, and mounted on
/var/lib/glance on both controller nodes. Reliable shared storage is
highly recommended for production; also note that alternatives exist
(for instance, using the swift or ceph backends).

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for Glance
*   Do not change any option
*   Under *Deployment*, remove the node that is assigned to the **glance-server** role, and drag `cluster1` to the **glance-server** role
*   Click on *Apply* to deploy Glance

### Deploy Barclamps / OpenStack / Cinder

**N.B.!** The cinder volumes will be stored on the compute node. The
controller nodes are not used to allow easy testing of failover. On a
real setup, using a SAN to store the volumes would be recommended.

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for Cinder
*   Change the following options:
    * Change *Type of Volume* to **Local file**
*   Under *Deployment*, remove the node that is assigned to the **cinder-controller** role, and drag `cluster1` to the **cinder-controller** role
*   Under *Deployment*, remove the node that is assigned to the **cinder-volume** role, and drag **compute1** to the **cinder-volume** role
*   Click on *Apply* to deploy Cinder

### Deploy Barclamps / OpenStack / Neutron

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for Neutron
*   Do not change any option
*   Under *Deployment*, remove the node that is assigned to the **neutron-server** role, and drag `cluster1` to the **neutron-server** role
*   remove the node that is assigned to the **neutron-l3** role, and drag and drop `cluster1` to **neutron-l3** role
*   Click on *Apply* to deploy Neutron

### Deploy Barclamps / OpenStack / Nova

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for Nova
*   Do not change any option
*   Under *Deployment*:
    * remove all nodes which are assigned to roles such as **nova-multi-controller** and **nova-multi-compute-xen**
    * drag `cluster1` to the **nova-multi-controller** role
    * drag **compute1** to the **nova-multi-compute-qemu** role
*   Click on *Apply* to deploy Nova

### Deploy Barclamps / OpenStack / Horizon

*   Go to tab *Barclamps* → *OpenStack* and click on *Create* for Horizon
*   Do not change any option
*   Under *Deployment*, remove the node that is assigned to the **nova_dashboard-server** role, and drag `cluster1` to the **nova_dashboard-server** role
*   Click on *Apply* to deploy Horizon

## Playing with Cloud

### Introduction

*   To log into the OpenStack Dashboard (Horizon):
    * In the Crowbar web UI, click on *Nodes*
    * Click on `controller1`
    * Click on the **OpenStack Dashboard (admin)** link
    * login: `admin`, password: `crowbar`
*   Choose the `Project` tab and for *Current Project* select `openstack`

### Upload image

*   Go to Images & Snapshots from Manage Compute section

*   Click on **Create Image** button and provide the following data:
    * *Name* - image name
    * *Image Source* - Image File
    * *Image File* - click on Browse button to choose image file
    * Format - QCOW2 - QEMU Emulator
    * Minimum Disk GB - 0 (no minimum)
    * Minimum RAM MB - 0 (no minimum)
    * Public - check this option
    * Protected - leave unchecked
*   Click on **Create Image** button to proceed and upload image

### Launching VM instance

*   Go to Instances from Manage Compute section
*   Click on Launch Instance button
*   In the *Details* tab set up
    * Availability Zone - nova
    * Instance Name - name of new VM
    * Flavor - `m1.tiny`
    * Instance Count - 1
    * Instance Boot Source - Boot from image
    * Image Name - choose uploaded image file
*   in Networking tab set up
    * drag and drop fixed network from Available Networks to Selected Networks
*   click on Launch button and wait until new VM instance will be ready

## Playing with High-Availability

### Introduction

*   open console to `controller1`, `controller2` and compute1 nodes and login there
*   on `controller1` and `controller2` run `crm_mon` command
*   on `controller1` run:

        . .openrc
        nova service-list
        nova list

### Failover scenarios for services

*   on `controller1` or `controller2` try to kill OpenStack services
    using commands like:

        pkill openstack-keystone
        pkill openstack-glance
        pkill openstack-nova

*   watch on consoles with `crm_mon` how all services are bringing up by pacemaker

### Failover scenarios for nodes

*   on `controller1` run `crm_mon` command
*   kill `controller2` node via `halt` or `shutdown -h now`
*   watch on consoles with `crm_mon` how all services are bringing up by pacemaker

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
