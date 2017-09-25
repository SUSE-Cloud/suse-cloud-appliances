#!/bin/bash

set -e

export PATH="$PATH:/sbin:/usr/sbin/"

# The appliance-firstboot service will deal with all the crowbar-init bits; we
# need to wait for this to be completed. And one way to check this is to check
# if the service is enabled, because at the end of the service, it disables
# itself.
while systemctl -q is-enabled appliance-firstboot; do
    echo "Waiting for appliance-firstboot to complete..."
    sleep 2
done

# Simply don't fail on zypper being already used, and retry a bit instead
export ZYPP_LOCK_TIMEOUT=120

# To trick install-suse-clouds check for "screen". It should be safe
# to run without screen here, as install-suse-cloud won't pull the network
# from eth0 because we patched the network cookbook accordingly.
export STY="dummy"

# ensure cloud_admin pattern is fully installed
# otherwise the check in install-suse-cloud will fail.
zypper -n install -t pattern cloud_admin

install-suse-cloud -v

. /etc/profile.d/crowbar.sh
crowbar network allocate_ip default cloud7-admin.openstack.site public host
chef-client
