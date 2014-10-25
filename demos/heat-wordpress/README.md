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
[the prerequisites described in the general HOWTO](../../HOWTO.md#prerequisites).

Then depending on your preferred hypervisor, simply run:

    ./build.sh virtualbox

or

    ./build.sh libvirt

This will perform the following steps:

*   Build admin, controller, and compute nodes via Vagrant
*   Set aliases in Crowbar for the controller and compute nodes
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

N.B. All steps run by `./build.sh` are idempotent, so you can safely
run it as many times as you need.

If you prefer to perform any of these steps manually as part of the
demo (e.g. creating the proposals and/or preparing the cloud for the
demo), you can easily comment those steps out of `build.sh` or
`prep-wordpress-project.sh`.

## Showing the demo

**FIXME**

*   Log in to the OpenStack dashboard as `suseuser`
*   Click on *Orchestration*
*   Create
*   Upload `.json` file
*   Name
*   Launch
*   Watch teh shiney
