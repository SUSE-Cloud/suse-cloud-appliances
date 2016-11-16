#!/bin/bash

set -e

export PATH="$PATH:/sbin:/usr/sbin/"

# The appliance may install packages on first boot, so allow zypper to wait
# for this to complete
export ZYPP_LOCK_TIMEOUT=120

# To trick install-suse-clouds check for "screen". It should be safe
# to run without screen here, as install-suse-cloud won't pull the network
# from eth0 because we patched the network cookbook accordingly.
export STY="dummy"

# ensure cloud_admin pattern is fully installed
# otherwise the check in install-suse-cloud will fail.
zypper -n install -t pattern cloud_admin

# work around https://bugzilla.novell.com/show_bug.cgi?id=895417
install -o chef -g chef -m 750 -d /var/run/chef

install-suse-cloud -v

. /etc/profile.d/crowbar.sh
crowbar network allocate_ip default cloud7-admin.openstack.site public host
chef-client
