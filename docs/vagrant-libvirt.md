# Using Vagrant with libvirt

There is a nice
[`vagrant-libvirt` plugin](https://github.com/pradels/vagrant-libvirt)
available, which you could install via:

    vagrant plugin install vagrant-libvirt

**However** there are several known bugs with the plugin for which the
fixes are not yet released, including:

*   [#252](https://github.com/pradels/vagrant-libvirt/pull/252) and
    [#256](https://github.com/pradels/vagrant-libvirt/pull/256)
    -- required if sharing disks between VMs (in particular, **the
    [HA demo](../demos/HA/) requires a shared SBD disk for cluster
    fencing**)
*   [#255](https://github.com/pradels/vagrant-libvirt/pull/255)
    -- required if using the plugin from git
*   [#261](https://github.com/pradels/vagrant-libvirt/pull/261)
    -- required if using a pre-release version of Vagrant from its
    [git `master` branch](https://github.com/mitchellh/vagrant)
*   [#262](https://github.com/pradels/vagrant-libvirt/pull/262)
    -- required if using ruby-libvirt >= 0.5
*   [#263](https://github.com/pradels/vagrant-libvirt/pull/263)
    -- required to allow setting cache mode on additional disks

## Addressing known bugs

If you are using one of the [pre-canned demos](../demos/) then these
steps are taken care of automatically by `build.sh`.

Otherwise, if any of these bugs affect you (especially if you are
planning to try [the HA demo](../demos/HA/)), you have two options.
One is to simply use VirtualBox instead.  This will provide an easier
installation, although there are some minor drawbacks
[already mentioned in the prerequisites document](prerequisites.md#hypervisor).

The other option is to use specially patched unofficial versions of
`vagrant-libvirt` and associated gems.  This is more complicated,
although we have made it easier by automating the installation via
Ruby's *bundler* utility and
[the provided `Gemfile` / `Gemfile.lock`](../vagrant/Gemfile).

### Installing patched gems via `bundle install`

Firstly you will need some development packages, since some of the
gems need to be compiled against pre-installed libraries.

On openSUSE:

    sudo zypper install {ruby,libvirt,libxml2,libxslt}-devel rubygem-bundler

On Fedora:

    sudo yum install {ruby,libvirt,libxml2,libxslt}-devel rubygem-bundler

On Ubuntu:

    sudo apt-get install libxslt-dev ruby-dev libxml2-dev ruby-bundler

Then install the gems described in
[the provided `Gemfile` / `Gemfile.lock`](../vagrant/Gemfile):

    # First cd to the directory where you cloned the git repository!
    cd vagrant
    bundle install --path vendor/bundle

If during installation, you get errors associated with `nokogiri`,
try:

    bundle config build.nokogiri --use-system-libraries

and then re-run the installation.

Once bundler has finished installing, every time you want to run
vagrant, you **must** be in this same directory which contains
`Gemfile.lock`, and you **must** prefix **every** `vagrant` command
with `bundle exec`, e.g.:

    bundle exec vagrant up admin
    bundle exec vagrant status

etc.

#### Updating an existing box

**CAUTION!** If you are using libvirt, it is not sufficient to do
`vagrant box update` or `vagrant box add --force`, or even `vagrant box
remove`; you will also have to manually remove the old image from
`/var/lib/libvirt/images` and then do:

    virsh pool-refresh default

before adding the new version, due to
[this bug](https://github.com/pradels/vagrant-libvirt/issues/85#issuecomment-55419054).

## Trouble-shooting other problems with `vagrant-libvirt`

*   **`vagrant up` results in an error `Call to virStorageVolGetInfo
    failed: cannot stat file`.**
    
    This is https://github.com/pradels/vagrant-libvirt/issues/51 and
    your libvirt default pool is probably corrupt (e.g. by directly
    deleting image files from it without `virsh vol-delete`).  Do
    `virsh pool-refresh default` and try again.

*   **`vagrant up` fails with some other error.**

    vagrant-libvirt is not yet robust at cleaning up after failures,
    especially concerning disks.  The following process can often
    clear a transient error:

    *   `vagrant destroy`
    *   Manually delete any associated disk volumes which got
        left behind in `/var/lib/libvirt/images`.
    *   `virsh pool-refresh default`
    *   `vagrant up`

    See [this bug](https://github.com/pradels/vagrant-libvirt/issues/85#issuecomment-55419054)
    for more information.
