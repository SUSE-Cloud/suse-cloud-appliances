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
baseUpdateSysConfig /etc/sysconfig/keyboard KEYTABLE us.map.gz
baseUpdateSysConfig /etc/sysconfig/network/config FIREWALL no
baseUpdateSysConfig /etc/sysconfig/network/config NETWORKMANAGER no
baseUpdateSysConfig /etc/sysconfig/SuSEfirewall2 FW_SERVICES_EXT_TCP 22\ 80\ 443
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT lat9w-16.psfu

chown root:root /studio/build-custom
chmod 755 /studio/build-custom
# run custom build_script after build
if ! /studio/build-custom; then
    cat <<EOF

*********************************
/studio/build-custom failed!
*********************************

EOF
    exit 1
fi

chown root:root /studio/suse-studio-custom
chmod 755 /studio/suse-studio-custom
test -d /studio || mkdir /studio

cp /image/.profile /studio/profile
cp /image/config.xml /studio/config.xml
rm -rf /studio/overlay-tmp
rm -rf /usr/share/doc || :
true

#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
c_rehash
