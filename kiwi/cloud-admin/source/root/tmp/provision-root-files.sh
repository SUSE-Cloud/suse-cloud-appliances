#!/bin/bash

set -e

# Vagrant's file provisioner runs as the vagrant user:
# http://docs.vagrantup.com/v2/provisioning/file.html
# so files intended for root also have to be moved to
# the right place.

mkdir -p /root/bin
mv /tmp/setup-node-aliases.sh /root/bin

mv /tmp/crowbar_batch /tmp/barclamp_lib.rb /opt/dell/bin
mv /tmp/*.yaml /root
