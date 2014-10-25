#!/bin/bash

set -e

admin_ip="$1"
sbd_device="$2"

# Set up SBD disk
zypper -n in sbd
/usr/sbin/sbd -d $sbd_device create

# Mount NFS export for glance
echo "${admin_ip}:/var/lib/glance /var/lib/glance nfs defaults 0 2" >> /etc/fstab
mkdir -p /var/lib/glance
mount /var/lib/glance
