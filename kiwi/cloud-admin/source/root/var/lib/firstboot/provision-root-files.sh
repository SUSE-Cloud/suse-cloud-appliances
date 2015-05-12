#!/bin/bash

set -e

# This is a near clone of the same file which gets provisioned
# by Vagrant.  The idea is to minimise differences between the
# Vagrant box and the appliance .iso.


cd /var/lib/firstboot

# These lines intentionally left blank to ease comparison
# with corresponding Vagrant file.

mkdir -p /root/bin
mv setup-node-aliases.sh /root/bin

mv *.yaml /root
