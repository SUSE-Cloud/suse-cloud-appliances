#!/bin/bash
#
# This script determines which repositories get embedded within
# the admin node appliance.

repos=(
    #SLES12-SP2-Pool # not needed since we have installation media
    #SLES12-SP2-Updates # embedded within SUSE-OPENSTACK-CLOUD-7-DEPS

    #SLE12-HA-SP2-{Pool,Updates} # embedded within SUSE-OPENSTACK-CLOUD-7-DEPS

    #SUSE-Cloud-7-Pool     # not needed since we have installation media
    #SUSE-Cloud-7-Updates  # not needed since we're using a Devel:Cloud:7:Staging .iso

    # Devel:Cloud:7
    # Devel:Cloud:7:Staging
)

function bind_mount {
    src="$1" mnt="$2"
    if mount | grep -q " $mnt "; then
        echo "already mounted: $mnt"
    else
        mkdir -p "$mnt"
        if mount --bind "$src" "$mnt"; then
            echo "mount succeeded: $mnt"
        else
            echo >&2 "Failed to mount $src on $mnt"
            exit 1
        fi
    fi
}

function setup_overlay {
    : ${MIRROR_DIR:=/data/install/mirrors}
    here=$( cd `dirname "$0"`; pwd -P )
    tftpboot=$here/source/root/srv/tftpboot
    bind_mount /mnt/suse-cloud-sle12-deps $tftpboot/suse-12.2/install
    bind_mount /mnt/suse-cloud-7          $tftpboot/suse-12.2/repos/Cloud
    for repo in "${repos[@]}"; do
        bind_mount $MIRROR_DIR/$repo $tftpboot/suse-12.2/repos/$repo
    done
}

setup_overlay
