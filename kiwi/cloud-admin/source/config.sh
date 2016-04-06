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


# Enable sshd
chkconfig sshd on

#======================================
# Sysconfig Update
#--------------------------------------
echo '** Update sysconfig entries...'
baseUpdateSysConfig /etc/sysconfig/keyboard KEYTABLE us.map.gz
baseUpdateSysConfig /etc/sysconfig/network/config FIREWALL no
baseUpdateSysConfig /etc/init.d/suse_studio_firstboot NETWORKMANAGER no
baseUpdateSysConfig /etc/sysconfig/SuSEfirewall2 FW_SERVICES_EXT_TCP 22\ 80\ 443
baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT lat9w-16.psfu


#======================================
# Setting up overlay files 
#--------------------------------------
echo '** Setting up overlay files...'
mkdir -p /root/
mv /studio/overlay-tmp/files/root/DRBD.yaml /root/DRBD.yaml
chown root:root /root/DRBD.yaml
chmod 644 /root/DRBD.yaml
mkdir -p /etc/YaST2/
mv /studio/overlay-tmp/files/etc/YaST2/firstboot-suse-openstack-cloud.xml /etc/YaST2/firstboot-suse-openstack-cloud.xml
chown root:root /etc/YaST2/firstboot-suse-openstack-cloud.xml
chmod 644 /etc/YaST2/firstboot-suse-openstack-cloud.xml
mkdir -p /etc/
mv /studio/overlay-tmp/files/etc/motd /etc/motd
chown root:root /etc/motd
chmod 644 /etc/motd
mkdir -p /root/
mv /studio/overlay-tmp/files/root/NFS.yaml /root/NFS.yaml
chown root:root /root/NFS.yaml
chmod 644 /root/NFS.yaml
mkdir -p /root/bin/
mv /studio/overlay-tmp/files/root/bin/node-sh-vars /root/bin/node-sh-vars
chown root:root /root/bin/node-sh-vars
chmod 755 /root/bin/node-sh-vars
mkdir -p /root/bin/
mv /studio/overlay-tmp/files/root/bin/setup-node-aliases.sh /root/bin/setup-node-aliases.sh
chown root:root /root/bin/setup-node-aliases.sh
chmod 755 /root/bin/setup-node-aliases.sh
mkdir -p /root/
mv /studio/overlay-tmp/files/root/simple-cloud.yaml /root/simple-cloud.yaml
chown root:root /root/simple-cloud.yaml
chmod 644 /root/simple-cloud.yaml
test -d /studio || mkdir /studio
cp /image/.profile /studio/profile
cp /image/config.xml /studio/config.xml
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
rm -rf /studio/overlay-tmp
true

#======================================
# SSL Certificates Configuration
#--------------------------------------
echo '** Rehashing SSL Certificates...'
c_rehash
