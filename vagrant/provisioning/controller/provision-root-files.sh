#!/bin/bash

set -e

admin_ip="$1"

# Vagrant's file provisioner runs as the vagrant user:
# http://docs.vagrantup.com/v2/provisioning/file.html
# so files intended for root also have to be moved to
# the right place.

cd /tmp

sed -i "s,192.168.124.10,${admin_ip},g" upload-cirros

mkdir -p /root/bin
mv upload-cirros /root/bin
