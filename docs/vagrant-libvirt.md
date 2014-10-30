# Using Vagrant with libvirt

There is a nice
[`vagrant-libvirt` plugin](https://github.com/pradels/vagrant-libvirt)
available, which you can install via:

    vagrant plugin install vagrant-libvirt

However there are several known bugs with the plugin for which the
fixes are not yet released, including:

*   [#252](https://github.com/pradels/vagrant-libvirt/pull/252) and
    [#256](https://github.com/pradels/vagrant-libvirt/pull/256)
    -- required if sharing disks between VMs
*   [#255](https://github.com/pradels/vagrant-libvirt/pull/255)
    -- required if using the plugin from git
*   [#261](https://github.com/pradels/vagrant-libvirt/pull/261)
    -- required if using Vagrant from git
*   [#262](https://github.com/pradels/vagrant-libvirt/pull/262)
    -- required if using ruby-libvirt >= 0.5
*   [#263](https://github.com/pradels/vagrant-libvirt/pull/263)
    -- required to allow setting cache mode on additional disks

If any of these bugs affect you, you should instead consider running
`vagrant` via `bundle exec vagrant`.  This requires first installing
the gems described in `Gemfile.lock`:

    cd $git_repo_dir/vagrant
    bundle install --path vendor/bundle

Every subsequent time you want to run vagrant, you will need to be in
that same directory.

If you are using one of the [pre-canned demos](../demos/) then these
steps are taken care of automatically.

#### Updating an existing box

**CAUTION!** If you are using libvirt, it is not sufficient to do
`vagrant box update` or `vagrant box add --force`, or even `vagrant box
remove`; you will also have to manually remove the old image from
`/var/lib/libvirt/images` and then do:

    virsh pool-refresh default

before adding the new version, due to
[this bug](https://github.com/pradels/vagrant-libvirt/issues/85#issuecomment-55419054).

## Trouble-shooting problems with `bundle install`

Here are suggestions for dealing with some commonly encountered
issues when running `bundle install`:

*   **Compilation of a gem fails.**

    Check you have the corresponding development packages
    (e.g. `ruby-devel` on openSUSE or `ruby-dev` on Debian/Ubuntu).

*   **I get nokogiri errors.**

    Try:

        bundle config build.nokogiri --use-system-libraries

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
