#!/bin/bash -e

# Script for building SUSE Cloud admin appliance
#
# See ../build-lib.sh for more info.

here=$( dirname "$0" )
. $here/../build-lib.sh

# Determine minimum RAM required for use of tmpfs
if [ -e $here/source/root/srv/tftpboot/suse-11.3/install/content.key ]
then
    # This is a guess, but we need a *lot* in this case.
    : ${TMPFS_SIZE:=13500}
else
    cat <<EOF >&2
WARNING: It appears you do not have the installation media and repositories
set up in your overlay filesystem.  The image will be missing these.
Press Enter to continue or Control-C to quit ...
EOF
    read
    : ${TMPFS_SIZE:=8500}
fi

BOOT_CACHE_DIR=/var/cache/kiwi/bootimage
OUTPUT_DIR=image
TMP_DIR="${KIWI_BUILD_TMP_DIR:-build-tmp}"
CLEAN=

build_image "$@"
