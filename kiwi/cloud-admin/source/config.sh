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
echo "Configure image: [$kiwi_iname]..."

#======================================
# Mount system filesystems
#--------------------------------------
baseMount

#======================================
# Setup baseproduct link
#--------------------------------------
suseSetupProduct

#======================================
# Add missing gpg keys to rpm
#--------------------------------------
suseImportBuildKey

#======================================
# Activate services
#--------------------------------------
baseInsertService sshd

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 3

#======================================
# SuSEconfig
#--------------------------------------
suseConfig


#======================================
# Sysconfig Update
#--------------------------------------
echo '** Update sysconfig entries...'
baseUpdateSysConfig /etc/sysconfig/network/config FIREWALL no
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT lat9w-16.psfu


#======================================
# Custom changes for Cloud
#--------------------------------------
USE_YAST_FIRSTBOOT=1

if [ "$kiwi_type" == "oem" ]; then
    echo "** Customizing config for appliance..."
else
    # nothing yet
    true
fi

if [ "$kiwi_type" == "iso" ]; then
    echo "** Customizing config for live image..."
    mv /etc/issue.live /etc/issue
    mv /etc/YaST2/control.xml.live /etc/YaST2/firstboot.xml
else
    # remove live ISO files
    rm /etc/issue.live
    rm /etc/YaST2/control.xml.live
fi

if [ "$kiwi_type" == "vmx" -a -d /home/vagrant ]; then
    echo "** Customizing config for Vagrant..."
    mv /etc/issue.vagrant /etc/issue
    # one dhcp network interface for vagrant + one static network interface
    mv /etc/sysconfig/network/ifcfg-eth0.dhcp /etc/sysconfig/network/ifcfg-eth0
    mv /etc/sysconfig/network/ifcfg-eth0.static /etc/sysconfig/network/ifcfg-eth1
    # use firstboot service
    USE_YAST_FIRSTBOOT=0
else
    # files required by vagrant
    rm /etc/sudoers.d/vagrant
    rm -r /home/vagrant/
    # remove vagrant-specific files
    rm /etc/profile.d/EULA.sh
    rm /etc/issue.vagrant
    # static network config, one interface
    rm /etc/sysconfig/network/ifcfg-eth0.dhcp
    mv /etc/sysconfig/network/ifcfg-eth0.static /etc/sysconfig/network/ifcfg-eth0
fi

# Working around broken timezone support for SLE 12 in kiwi
systemd-firstboot --timezone=UTC

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

if [ $USE_YAST_FIRSTBOOT -eq 1 ]; then
    echo "** Enabling YaST firstboot..."
    baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_WELCOME_DIR /etc/YaST2/firstboot/
    baseUpdateSysConfig /etc/sysconfig/firstboot FIRSTBOOT_FINISH_FILE /etc/YaST2/firstboot/congratulate.txt
    touch /var/lib/YaST2/reconfig_system

    # Do not rely on yast2-firstboot to run our scripts as this create a
    # dependency loop for systemd (as firstboot is blocking other systemd
    # services), and makes it impossible for chef-solo to start services
    #chkconfig appliance-firstboot off
    echo "** Enabling firstboot service..."
    chkconfig appliance-firstboot on
    # prevent yast2 from calling the firstboot scripts
    baseUpdateSysConfig /etc/sysconfig/firstboot SCRIPT_DIR /usr/share/firstboot/scripts-no
else
    echo "** Enabling firstboot service..."
    chkconfig appliance-firstboot on

    # remove yast firstboot files
    zypper --non-interactive rm yast2-firstboot
    rm /etc/YaST2/firstboot.xml
    rm -r /etc/YaST2/firstboot/
    rm -r /usr/share/firstboot/licenses/
fi

echo "** Setting up zypper repos..."
# -K disables local caching of rpm files, since they are already local
# to the VM (or at least to its host in the NFS / synced folders cases),
# so caching would just unnecessarily bloat the VM.
zypper --non-interactive ar -K -t yast2 file:///srv/tftpboot/suse-12.2/x86_64/install DEPS-ISO

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

# Create the directory for cinder NFS storage
mkdir -p /var/lib/cinder
echo '/var/lib/cinder <%= @admin_subnet %>/<%= @admin_netmask %>(rw,async,no_root_squash,no_subtree_check)' >> /opt/dell/chef/cookbooks/nfs-server/templates/default/exports.erb

# Create the directory for shared nova instances storage
mkdir -p /var/lib/nova/instances
echo '/var/lib/nova/instances <%= @admin_subnet %>/<%= @admin_netmask %>(rw,async,no_root_squash,no_subtree_check)' >> /opt/dell/chef/cookbooks/nfs-server/templates/default/exports.erb

echo "** Enabling additional services..."
# helps with gpg in VMs
chkconfig haveged on
# we want ntpd to start early, as it doesn't reply to ntpdate 5 minutes,
# which can slow node discovery (new behavior happening because it
# doesn't synchronize with any other servers, see bsc#954982)
chkconfig ntpd on


#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
c_rehash


#======================================
# Umount kernel filesystems
#--------------------------------------
baseCleanMount

#======================================
# Exit safely
#--------------------------------------
exit 0
