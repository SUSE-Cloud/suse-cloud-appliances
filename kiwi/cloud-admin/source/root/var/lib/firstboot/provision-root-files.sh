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

gem install easy_diff-0.0.3.gem
mv crowbar_batch barclamp_lib.rb /opt/dell/bin
mv *.yaml /root
