#!/bin/bash

set -e

# Vagrant's file provisioner runs as the vagrant user:
# http://docs.vagrantup.com/v2/provisioning/file.html
# so files intended for root also have to be moved to
# the right place.

cd /tmp

mkdir -p /root/bin
mv setup-node-aliases.sh /root/bin

mv crowbar_batch barclamp_lib.rb /opt/dell/bin
mv *.yaml /root
