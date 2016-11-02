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
echo "** Enabling firstboot service..."
chkconfig appliance-firstboot on

# This avoids annoyingly long timeouts on reverse DNS
# lookups when connecting via ssh.
sed -i 's/^#\?UseDNS.*/UseDNS no/' /etc/ssh/sshd_config

# Default behaviour of less drives me nuts!
sed -i 's/\(LESS="\)/\1-X /' /etc/profile

echo "** Enabling services..."
# helps with gpg in VMs
chkconfig haveged on
chkconfig sshd on


#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
c_rehash
