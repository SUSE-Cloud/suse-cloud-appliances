#!/bin/bash -e

# Script for building SUSE Cloud admin appliance
#
# See ../build-lib.sh for more info.

here=$( dirname "$0" )
. $here/../build-lib.sh

: ${TMPFS_SIZE:=16500}

BOOT_CACHE_DIR=/var/cache/kiwi/bootimage
OUTPUT_DIR=image
TMP_DIR="${KIWI_BUILD_TMP_DIR:-build-tmp}"
CLEAN=

build_image "$@"
