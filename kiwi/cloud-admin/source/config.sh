#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for SUSE based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$name]..."

#======================================
# SuSEconfig
#--------------------------------------
echo "** Running suseConfig..."
suseConfig

echo "** Running ldconfig..."
/sbin/ldconfig

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct


#======================================
# Setup default runlevel
#--------------------------------------
baseSetRunlevel 3

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey


#======================================
# Sysconfig Update
#--------------------------------------
echo '** Update sysconfig entries...'
baseUpdateSysConfig /etc/sysconfig/network/config FIREWALL no
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT lat9w-16.psfu


#======================================
# Custom changes for Cloud
#--------------------------------------
echo '** Enabling YaST firstboot...'
baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_WELCOME_DIR /etc/YaST2/firstboot/
baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_FINISH_FILE /etc/YaST2/firstboot/congratulate.txt
touch /var/lib/YaST2/reconfig_system

echo "** Working around bug in YaST firstboot (bsc#974489)..."
sed -i '/\/etc\/init.d\/kbd restart/d' /usr/lib/YaST2/startup/Firstboot-Stage/S09-cleanup

echo "** Working around broken timezone support for SLE 12 in kiwi..."
cat <<EOF > /etc/sysconfig/clock
TIMEZONE="UTC"
DEFAULT_TIMEZONE="UTC"
EOF

echo "** Setting up zypper repos..."
# -K disables local caching of rpm files, since they are already local
# to the VM (or at least to its host in the NFS / synced folders cases),
# so caching would just unnecessarily bloat the VM.
#
# -G disables GPG check for the repository.
zypper ar -G -K -t yast2 file:///srv/tftpboot/suse-12.1/x86_64/install DEPS-ISO

echo "** Customizing config..."
# This avoids annoyingly long timeouts on reverse DNS
# lookups when connecting via ssh.
sed -i 's/^#\?UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

# Default behaviour of less drives me nuts!
sed -i 's/\(LESS="\)/\1-X /' /etc/profile

cat <<EOF >>/root/.bash_profile
if [ -e /tmp/.crowbar-nodes-roles.cache ]; then
  source /tmp/.crowbar-nodes-roles.cache
fi
EOF

echo "** Patching Crowbar for appliance..."
/patches/apply-patches
rm -rf /patches

# Scrap pointless 45 second tcpdump per interface
sed -i 's/45/1/' /opt/dell/chef/cookbooks/ohai/files/default/plugins/crowbar.rb

# Create the NFS export for shared storage for HA PostgreSQL and RabbitMQ
mkdir -p /nfs/{postgresql,rabbitmq}
echo '/nfs/postgresql <%= @admin_subnet %>/<%= @admin_netmask %>(rw,async,no_root_squash,no_subtree_check)' >> /opt/dell/chef/cookbooks/nfs-server/templates/default/exports.erb
echo '/nfs/rabbitmq <%= @admin_subnet %>/<%= @admin_netmask %>(rw,async,no_root_squash,no_subtree_check)' >> /opt/dell/chef/cookbooks/nfs-server/templates/default/exports.erb

# Create the directory for shared glance storage
mkdir -p /var/lib/glance
echo '/var/lib/glance <%= @admin_subnet %>/<%= @admin_netmask %>(rw,async,no_root_squash,no_subtree_check)' >> /opt/dell/chef/cookbooks/nfs-server/templates/default/exports.erb

echo "** Enabling services..."
chkconfig haveged on
chkconfig sshd on
chkconfig crowbar on


#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
c_rehash
