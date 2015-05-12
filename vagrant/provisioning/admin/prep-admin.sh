#!/bin/bash

set -e

cd /tmp

patch -d /opt/dell -p1 < barclamp-network-ignore-eth0.patch
patch -d /opt/dell -p1 < barclamp-provisioner-nfs-export.patch
patch -d /opt/dell -p1 < barclamp-pacemaker-ignore-target-role-changes.patch
patch -d /opt/dell -p1 -R < barclamp-provisioner-hae-check.patch

# Scrap pointless 45 second tcpdump per interface
sed -i 's/45/1/' /opt/dell/chef/cookbooks/ohai/files/default/plugins/crowbar.rb

# Create the directory for shared glance storage
mkdir -p /var/lib/glance

# Bypass the provisioner's check for HAE repos, since we're already
# providing these via the special SUSE-CLOUD-SLE11-SP3-DEPS installation media
# in /srv/tftpboot/suse-11.3/install
for repo in SLE11-HAE-SP3-{Pool,Updates}; do
    ln -s ../install /srv/tftpboot/suse-11.3/repos/$repo
done
