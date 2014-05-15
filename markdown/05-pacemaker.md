# Pacemaker barclamp


### Provides
# HA library code
### for other barclamps


### Installs the
# Pacemaker
## High-availability manager
Note: and web / CLI / desktop UIs.
Switch to Crowbar browser tab


# STONITH
**Configuration mode for STONITH:**

STONITH - Configured with STONITH Block Devices (SBD)


# SBD
Pre-configured on `/dev/sdc`


# DRBD
**Prepare cluster for DRBD:** true


# Pacemaker GUI:
**Setup non-web GUI (hb_gui):**  true


### What's special about how
# SUSE Cloud
### uses Pacemaker with Crowbar?


## Chef LWRPs for Pacemaker

    pacemaker_clone "cl-#{service_name}" do
      rsc service_name
      action [:create, :start]
    end

Note: minimise disruption to existing cookbooks


`Chef::Provider::Pacemaker::Service`
Note:

- basic idea of usurping management of SysVinit services
- maintenance mode to deal with restarts triggered by config file changes


# DRBD


## `haproxy`
# Load Balancer


### Automatic
# cluster
### configuration

Note:
- Quorum
- Fencing shoot-out protection
- SBD auto-configuration


# UI extensions
### for flexible role allocation
