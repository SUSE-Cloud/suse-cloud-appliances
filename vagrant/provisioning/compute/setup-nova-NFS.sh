#!/bin/bash

set -e

admin_ip="$1"

# Mount NFS export for nova instances
zypper --non-interactive install nfs-client
echo "${admin_ip}:/var/lib/nova/instances /var/lib/nova/instances nfs defaults 0 2" >> /etc/fstab
mkdir -p /var/lib/nova/instances
mount /var/lib/nova/instances
