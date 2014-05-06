#!/bin/bash
#
# This script determines which repositories get embedded within
# the admin node appliance.

repos=(
    #SLES11-SP3-Pool # not needed since we have installation media
    #SLES11-SP3-Updates # embedded within SUSE-CLOUD-3-DEPS

    #SLE11-HAE-SP3-{Pool,Updates} # embedded within SUSE-CLOUD-3-DEPS

    #SUSE-Cloud-3.0-Pool     # not needed since we have installation media
    # SUSE-Cloud-3.0-Updates # not needed since we're using a Devel:Cloud:3:Staging .iso

    # Devel:Cloud:Shared:11-SP3
    # Devel:Cloud:Shared:11-SP3:Update
    # Devel:Cloud:3
    # Devel:Cloud:3:Staging
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
    bind_mount /mnt/suse-cloud-3-deps $tftpboot/suse-11.3/install
    bind_mount /mnt/suse-cloud-3      $tftpboot/repos/Cloud
    for repo in "${repos[@]}"; do
        bind_mount $MIRROR_DIR/$repo $tftpboot/repos/${repo/3.0/3}
    done
}

setup_overlay
