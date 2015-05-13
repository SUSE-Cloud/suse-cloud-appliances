#!/bin/bash

set -e

export PATH="$PATH:/sbin:/usr/sbin/"

# SLES11_SP3 should not be checked since we are using the -DEPS media in lieu
# SLES11-SP3-Pool is not required due to presence of the -DEPS media (and
#                 normally isn't due to presence of SP3 media)
# SUSE-Cloud-5-Pool is not required since it simply duplicates the Cloud media
# SUSE-Cloud-5-Updates is not required since updates are included in this Cloud media
# SLE11-HAE-SP3-Pool is not required since HAE is included in the -DEPS media
# SLE11-HAE-SP3-Updates is not required since HAE is included in the -DEPS media
export REPOS_SKIP_CHECKS="SLES11_SP3 SLES11-SP3-Pool
                          SUSE-Cloud-5-Pool SUSE-Cloud-5-Updates
                          SLE11-HAE-SP3-Pool SLE11-HAE-SP3-Updates"

# To trick install-suse-clouds check for "screen". It should be save
# to run with screen here. As install-suse-cloud won't pull the network
# from eth0 because of the above patch.
export STY="dummy"

# ensure cloud_admin pattern is fully installed
# otherwise the check in install-suse-cloud will fail.
zypper -n install -t pattern cloud_admin

# work around https://bugzilla.novell.com/show_bug.cgi?id=895417
install -o chef -g chef -m 750 -d /var/run/chef

install-suse-cloud -v

. /etc/profile.d/crowbar.sh
crowbar network allocate_ip default cloud5-admin.openstack.site public host
chef-client
