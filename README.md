# Vagrant resources for SUSE Cloud

This repository contains resources for rapid virtualized deployment of
[SUSE Cloud](https://www.suse.com/products/suse-cloud/) via
[Vagrant](http://www.vagrantup.com/).

## Contents

*   a [HOWTO guide](HOWTO.md) documenting how to use Vagrant and the
    provided [`Vagrantfile`](vagrant/Vagrantfile) to deploy a
    SUSE Cloud environment of (by default) 4 VMs via a single
    `vagrant up` command
*   an [HA guide](HA-GUIDE.md) documenting how to use these resources to
    deploy a highly-available cloud from scratch

Currently the Vagrant boxes and .iso images required are built on
SUSE's Internal Build Service a.k.a. IBS which is accessible only to
employees.  (Employees please follow
[this HOWTO](https://etherpad.nue.suse.com/p/cloud-vagrant).)  However
the goal is to make the Vagrant boxes available in the near future via
https://vagrantcloud.com/suse so that they will be automatically
downloaded on demand.  If you are external and would like these files
urgently, please
[contact us](https://forums.suse.com/forumdisplay.php?65-SUSE-Cloud)
and we can probably sort something out!

In theory if you had the time and patience, you could probably build
them yourself from scratch using the below resources from this
repository, although that is not recommended:

*   [resources for building the KIWI appliances](kiwi/)
*   [resources for building the Vagrant boxes](vagrant/) from the KIWI
    appliances (since these were originally built,
    [KIWI has learnt how to build Vagrant boxes directly](https://github.com/openSUSE/kiwi/pull/353),
    so in the near future we should be able to remove these)

## Support, bugs, development etc.

If you experience a bug or other issue, or want to check the list
of known issues and other ongoing development, please refer to the
[github issue tracker](https://github.com/SUSE-Cloud/suse-cloud-vagrant/issues/).

## History

The resources were originally built for
[an OpenStack HA workshop session given on 2014/05/15 at the OpenStack summit in Atlanta](http://openstacksummitmay2014atlanta.sched.org/event/d3db2188dfed4459f8fbd03f5b405b81#.U4C6NXWx1Qo).
Video, slides, and other material from that workshop are available
[here](https://github.com/aspiers/openstacksummit2014-atlanta).
