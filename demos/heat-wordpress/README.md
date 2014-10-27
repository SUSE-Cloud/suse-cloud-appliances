# Deploying Wordpress on OpenStack via Heat

This demo shows how easy it is to use
[OpenStack Orchestration (a.k.a. Heat)](https://wiki.openstack.org/wiki/Heat)
to deploy a Wordpress blogging application stack on OpenStack.

It uses a Heat template file which installs two instances: one running
a WordPress deployment, and the other using a local MySQL database to
store the data.

The demo is based on
[a SUSE TechTalk by Rick Ashford](suse_techtalk_orchestrating_service_deployment_in_suse_cloud.pdf);
see the slides for more information.

## Preparing the demo

First ensure you have
[the described prerequisites](../../docs/prerequisites.md).

Next, read this whole section before running anything :-)

Then depending on your preferred hypervisor, simply run:

    ./build.sh virtualbox

or

    ./build.sh libvirt

This will perform the following steps:

*   Build admin, controller, and compute nodes via Vagrant
*   Run [`/root/bin/setup-node-aliases.sh`](../../vagrant/provisioning/admin/setup-node-aliases.sh)
    to set aliases in Crowbar for the controller and compute nodes
*   Create and apply a standard set of Crowbar proposals
*   Download the Wordpress and MySQL VM appliances
*   Prepare the OpenStack cloud for the demo:
    *   Create a new `Wordpress` project
    *   Create a new `suseuser` with password `suseuser`
    *   Associate the user with the project
    *   Create `MySQLSecGroup` and `WWWSecGroup` security groups
        and populate with the necessary firewall rules.
    *   Upload the VM appliance images to Glance.
    *   Generate a key pair for the `suseuser`
    *   Subtitute the correct ids into the heat template
*   Copy the `suseuser.pem` private key and the generated
    `heat-template-wordpress.json` back into this directory
    so that they can be used from the demo host.

You can also optionally tune the number, size, and shape of the VMs
being booted, by editing
[`vagrant/configs/2-controllers-1-compute.yaml`](../../vagrant/configs/2-controllers-1-compute.yaml),
and tune the barclamp proposal parameters by editing
[`vagrant/provisioning/admin/HA-cloud.yaml`](../../vagrant/provisioning/admin/HA-cloud.yaml).

N.B. All steps run by `./build.sh` are idempotent, so you can safely
run it as many times as you need.

If you prefer to perform any of these steps manually as part of the
demo (e.g. creating the proposals and/or preparing the cloud for the
demo), you can easily comment those steps out of `build.sh` or
`prep-wordpress-project.sh`.

For example, you could comment out the lines which call
`crowbar batch` near the end of the script, and then apply
the proposals manually.

If you want, you can even mix'n'match the manual and automatic
approaches, by adding `--include` / `--exclude` options to the
invocation of `crowbar batch` filtering which proposals get applied,
and/or by editing
[`/root/simple-cloud.yaml`](../../vagrant/provisioning/admin/simple-cloud.yaml)
on the Crowbar admin node, and commenting out certain proposals.
However, you should be aware that the proposals need to be applied in
the order given, regardless of whether they are applied manually or
automatically.

## Showing the demo

**FIXME - need some more detail here**

*   Log in to the OpenStack dashboard as `suseuser`
*   Click on *Orchestration*
*   Launch a new stack
*   Upload the `.json` file
*   Give the name `Wordpress` to the new stack 
*   Give a password `suseuser` for lifecycle operations
*   Click the launch button
*   Watch teh shiney

## Performing Vagrant operations

If you want to use `vagrant` to control the VMs, e.g. `vagrant halt` /
`destroy`, then first `cd` to the `vagrant/` subdirectory of the git
repository:

    cd ../../vagrant
