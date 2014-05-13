# Pacemaker barclamp


### Installs the
# Pacemaker
### High-availability manager
Note: Switch back and forth to and from Crowbar browser tab


# SBD
Pre-configured on `/dev/sdc`


# STONITH
**Configuration mode for STONITH:**

STONITH - Configured with STONITH Block Devices (SBD)


# DRBD
**Prepare cluster for DRBD:** true


# Pacemaker GUI:
**Setup non-web GUI (hb_gui):**  true


### What's special about how
# SUSE Cloud
### uses Pacemaker with Crowbar?


`Chef::Provider::Pacemaker::Service`


# Load Balancer
### configuration


### Automatic
# cluster
### configuration

Note:
- Quorum
- Fencing shoot-out protection
- SBD auto-configuration


### Flexible
# configuration

Clusters / nodes / roles
