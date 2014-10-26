#!/bin/bash

set -e

admin_ip="$1"

# Mount NFS export for glance
echo "${admin_ip}:/var/lib/glance /var/lib/glance nfs defaults 0 2" >> /etc/fstab
mkdir -p /var/lib/glance
mount /var/lib/glance
