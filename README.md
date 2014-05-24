# Vagrant resources for SUSE Cloud

This repository contains resources for rapid virtualized deployment of
[SUSE Cloud](https://www.suse.com/products/suse-cloud/) via
[Vagrant](http://www.vagrantup.com/).

## Contents

* [resources for building the KIWI appliances](kiwi/)
* [resources for building the Vagrant boxes](vagrant/) from the KIWI appliances
  (since these were originally built, [KIWI has learnt how to build Vagrant boxes
  directly](https://github.com/openSUSE/kiwi/pull/353), so in the near future
  we should be able to remove these)
* a [`Vagrantfile`](vagrant/Vagrantfile) which allows deployment of a SUSE Cloud
  environment in 4 VMs via a single `vagrant up` command

## History

The resources were originally built for
[an OpenStack HA workshop session given on 2014/05/15 at the OpenStack summit in Atlanta](http://openstacksummitmay2014atlanta.sched.org/event/d3db2188dfed4459f8fbd03f5b405b81#.U4C6NXWx1Qo).
Video, slides, and other material from that workshop are available
[here](https://github.com/aspiers/openstacksummit2014-atlanta).
