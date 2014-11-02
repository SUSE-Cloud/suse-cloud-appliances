# Running the HA demo on Windows

Firstly make sure you have all
[the prerequisites](../../docs/prerequisites.md).  In particular,
ideally you will have installed
[Git for Windows](http://msysgit.github.io/) which provides a
[GNU-like `bash` environment](http://msysgit.github.io/#bash) from
which you can run the standard [`build.sh` script provided](build.sh).
However this page explains how to run the demo both with and without
it installed.

## Running via Git Bash

If you have Git for Windows installed, simply
launch [Git BASH](http://msysgit.github.io/#bash) from the Start menu,
make sure you are in the right directory and then run `build.sh`:

    cd path/to/this/git/repository
    cd demos/HA

and then continue following [the normal README](README.md).

## Running without Git Bash

If you don't have Git for Windows installed, you will have to type
some commands manually, as follows.

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
