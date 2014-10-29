# Recovering a SUSE Cloud controller cluster to a healthy state

Abusing a test cluster to see how it handles failures is fun :-)
However depending on the kind of abuse, you might find that one of
your nodes ends up getting
[fenced](http://en.wikipedia.org/wiki/Fencing_(computing)),
i.e. automatically rebooted.  This is the correct behaviour - it is
required in order to protect your cluster against data loss or
corruption.

However, recovering a degraded (but still functioning) cluster
to full strength requires some manual intervention.  Again, this
is intentional design in order to protect the cluster.

This document explains how to spot fencing, and what to do if it
happens.

## Symptoms of a degraded cluster

*   A VM suddenly reboots without you asking it to.
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

Therefore to tell the node it can safely rejoin the cluster,
[connect to the node](../../docs/HOWTO.md#connecting-to-the-vms)
and type:

    rm /var/spool/corosync/block_automatic_start

Now you should be able to start the cluster again, e.g.

    service openais start

However, this is not sufficient, because all nodes (including the
Crowbar admin server node) need to be aware that this node is back
online.  Whilst Pacemaker takes care of that to a large extent,
Crowbar and Chef still need to do one or two things.  So you need
to ensure that the node is (re-)registered with Crowbar:

    service crowbar_join start

And to be safe, also trigger a Chef run on the other
controller node by connecting to it and running:

    chef-client

If you get stuck, the following log files on the admin server node
should prove informative when debugging Chef:

*   `/var/log/crowbar/chef-client/*.log` (there is one per node)

Chef will also automatically run every 15 minutes on each node,
and log to `/var/log/chef/client.log` on the node itself.

This is the main log for the Crowbar server:

*   `/var/log/crowbar/production.log`

See the official SUSE Cloud documentation for
[a full list of log files](https://www.suse.com/documentation/suse-cloud4/book_cloud_deploy/data/cha_deploy_logs.html).
