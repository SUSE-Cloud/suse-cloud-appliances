#!/bin/bash

set -e

cd /opt/dell/
patch -p1 < /tmp/barclamp-network-ignore-eth0.patch
patch -p1 < /tmp/barclamp-provisioner-nfs-export.patch
patch -p1 < /tmp/barclamp-pacemaker-ignore-target-role-changes.patch

cp /tmp/network.json /etc/crowbar/network.json
rm -f /tmp/network.json

# Scrap pointless 45 second tcpdump per interface
sed -i 's/45/5/' /opt/dell/chef/cookbooks/ohai/files/default/plugins/crowbar.rb

# Create the directory for shared glance storage
mkdir -p /var/lib/glance

# Bypass the provisioner's check for HAE repos, since we're already
# providing these via the special SUSE-CLOUD-SLE11-SP3-DEPS installation media
# in /srv/tftpboot/suse-11.3/install
for repo in SLE11-HAE-SP3-{Pool,Updates}; do
    ln -s ../suse-11.3/install /srv/tftpboot/repos/$repo
done
