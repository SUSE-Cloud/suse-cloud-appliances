# Recovering a SUSE OpenStack Cloud controller cluster to a healthy state

[Abusing a test cluster to see how it handles failures](cluster-failover.md)
is fun :-)  However depending on the kind of abuse, you might find that
one of your nodes refuses to rejoin the cluster.

This is most likely because it was not cleanly shut down - either
because you deliberately killed it, or because it got
[fenced](http://en.wikipedia.org/wiki/Fencing_(computing)),
i.e. automatically killed by the
[STONITH](http://clusterlabs.org/doc/crm_fencing.html) mechanism.
This is the correct behaviour - it is required in order to protect
your cluster against data loss or corruption.

However, recovering a degraded (but *still functioning*) cluster to
full strength requires some manual intervention.  Again, this is
intentional design in order to protect the cluster.

This document explains how to spot fencing, and what to do if it
happens.

## Symptoms of a degraded cluster

Here are some of the symptoms you may see:

*   A VM rebooted without you asking it to.
*   The Crowbar web UI may show a red bubble icon next to
    a controller node.
*   The Hawk web UI stops responding on one of the controller
    nodes.  (You should still be able to use the other one.)
*   Your `ssh` connection to a controller node freezes.
*   OpenStack services will stop responding for a short while.

## Recovering from a degraded cluster

Ensure that the node which got fenced is booted up again.  It will not
automatically rejoin the cluster, because we only have a 2-node
cluster, so quorum is impossible therefore we have to defend against
fencing loops.  (This is the "Do not start corosync on boot after
fencing" setting in the
[Pacemaker barclamp proposal](http://192.168.124.10:3000/crowbar/pacemaker/1.0/proposals/cluster1).)

### Recovering the Pacemaker cluster

Therefore to tell the node it can safely rejoin the cluster,
[connect to the node](../../docs/HOWTO.md#connecting-to-the-vms)
and type:

    rm /var/spool/corosync/block_automatic_start

Now you should be able to start the cluster again, e.g.

    service openais start

### Recovering Crowbar and Chef

However, this is not sufficient, because all nodes (including the
Crowbar admin server node) need to be aware that this node is back
online.  Whilst Pacemaker takes care of that to a large extent,
Crowbar and Chef still need to do one or two things.  So you need
to ensure that the node is (re-)registered with Crowbar:

    service crowbar_join start

and then trigger a Chef run on the other controller node by connecting
to it and running:

    chef-client

## Failcounts

In some circumstances, some cluster resources may have exceeded their
[maximum failcount](http://clusterlabs.org/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/s-failure-migration.html),
in which case they will need manually "cleaning up" before they start
again.  This Pacemaker feature is provided in order to prevent broken
resources from "flapping" in an infinite loop.  Clean-up of all
stopped resources can be done with a single command:

    crm_resource -o | \
        awk '/\tStopped |Timed Out/ { print $1 }' | \
        xargs -n1 crm resource cleanup

You can also clean up services individually via the
[Hawk web interface](README.md#hawk-web-ui).

### Maintenance mode

Another complication which can occasionally crop up during recovery is
related to Pacemaker's "maintenance mode".  During normal operation,
`chef-client` sometimes needs to place a node into
[maintenance mode](http://crmsh.nongnu.org/crm.8.html#cmdhelp_node_standby)
(e.g. so that it can safely restart a service after a configuration
file has been updated).  Rather than risk "flapping" the maintenance
mode status multiple times per run, it keeps the node in standby until
the `chef-client` run finishes.  However if the run fails, the node
can be left in maintenance mode, requiring manual remediation.  You
can tell if this happens because for all resources on that node,
`crm_mon` etc. will show `(unmanaged)`, and Hawk will display a little
wrench icon.

You can disable maintenance mode very easily from the node itself:

    crm node ready

## Summary

Currently, cluster recovery can be a bit complicated, especially in
the 2 node case.  We have plans to make this process more
user-friendly in the near future!

## Debugging

Please see [this debugging page](../../docs/debugging.md).
