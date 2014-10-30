# Running the HA demo on Windows

Firstly make sure you have all
[the prerequisites](../../docs/prerequisites.md).

Then open a command shell.

If you have less than 16GB of RAM (but at least 8GB), type this:

    set VAGRANT_CONFIG_FILE=configs/2-controllers-0-compute.yaml

Make sure you are in the right directory:

    cd path\to\this\git\repository
    cd vagrant

Your shell should now be in the directory which contains
`Vagrantfile`, `configs/` etc.  If not then the following will not work!

    vagrant up

This will take some time to boot all the nodes.  Once it's finished,
log into the admin node either via:

    vagrant ssh admin -- -l root

or simply via the console in the VirtualBox GUI.  The password is
`vagrant`.

Now type the following:

    setup-node-aliases.sh

If you have 16GB of RAM, type:

    crowbar batch build /root/HA-cloud.yaml

If you have less (but at least 8GB), instead type:

    crowbar batch build /root/HA-cloud-no-compute.yaml
