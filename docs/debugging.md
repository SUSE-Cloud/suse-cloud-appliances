# A crash course in debugging SUSE Cloud issues

**Please first check [the FAQ](FAQ.md).**

This is a very minimal guide to debugging SUSE Cloud issues.  You can
also consult the
[official product documentation](https://www.suse.com/documentation/suse-cloud4/book_cloud_deploy/data/cha_depl_trouble.html).

## Architecture

Understanding
[SUSE Cloud's architecture](https://www.suse.com/documentation/suse-cloud4/book_cloud_deploy/data/cha_depl_arch.html)
is an essential part of being able to effectively debug issues.

## Debugging Chef

There are three places where you might need to look for Chef
client failures:

1.  Applying Crowbar barclamp proposals will cause `chef-client` to
    immediately run on all nodes which that proposal affects.
    If something goes wrong, the following log files on the admin
    server node should prove informative:

    *   `/var/log/crowbar/chef-client/*.log` (there is one per node)

2.  Crowbar causes `chef-client` to run on each node on boot up, when
    the node registers against Crowbar via the `crowbar_join` service.
    The logs for this are found on the node itself, under

    *   `/var/log/crowbar/crowbar_join/`

3.  Chef will also automatically run every 15 minutes on each node,
    and log to `/var/log/chef/client.log` on the node itself.

## Debugging Crowbar

This is the main log for the Crowbar server:

*   `/var/log/crowbar/production.log`

## Debugging Pacemaker

Pacemaker logs to `/var/log/messages` on each node in the cluster.
Hawk has some very useful history exploration functionality which
makes it easier to get a chronologically sorted, cluster-wide view of
events.

Please also see [this guide to cluster recovery](../demos/HA/cluster-recovery.md).

## Other log files

See the official SUSE Cloud documentation for
[a full list of log files](https://www.suse.com/documentation/suse-cloud4/book_cloud_deploy/data/cha_deploy_logs.html).
