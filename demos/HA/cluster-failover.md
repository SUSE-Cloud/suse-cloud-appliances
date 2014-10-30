# Testing failover of the OpenStack infrastructure cluster

Firstly please note that this virtualized Vagrant environment is not a
fair reflection of a production cluster!  Whilst it should be
sufficiently robust for most testing and demonstration purposes,
there are some limitations.  This is particularly true if your host
machine does not have a lot of spare RAM after all VMs are fully up
and running OpenStack services.

## Introduction

*   [Connect to the `controller1` and `controller2` VMs](../../docs/HOWTO.md#connecting-to-the-vms)
*   On `controller1` and `controller2`, run `crm_mon` command.
*   You can also monitor the cluster from the
    [Hawk](http://clusterlabs.org/wiki/Hawk) web interface, via
    [`controller1`](http://192.168.124.81:7630) or
    [`controller2`](http://192.168.124.82:7631) (choose the one which
    you don't plan to kill during failover testing!)
*   On `controller1` run:

        source .openrc
        keystone user-list
        keystone service-list
        neutron net-list
        nova list   # (N.B. in 8GB environments you won't have nova)

## Failover scenarios for services

*   On `controller1` or `controller2` try to kill OpenStack services
    using commands like:

        pkill openstack-keystone
        pkill openstack-glance
        pkill openstack-nova

*   Watch `crm_mon` and/or Hawk to see how all services are kept running
    by Pacemaker.

## Failover scenarios for nodes

*   Kill the `controller2` VM by powering it off via your hypervisor.
*   Watch `crm_mon` and/or Hawk (on `controller1`!) to see how the
    active/passive services are failed over by Pacemaker.

At this point you should probably read
[how to recover a degraded cluster](cluster-recovery.md).
