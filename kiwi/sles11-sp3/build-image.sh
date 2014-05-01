#!/bin/bash -e

# ========================================================================
# Script for building Crowbar dev VM based on SUSE (openSUSE/SLES).
#
# Requires Kiwi (http://opensuse.github.io/kiwi/).
#
# Build performance:
# - Automatically builds in RAM (tmpfs) if there's about 5 GB free memory. This
#   brings the build time down from about 10 mins to 2 mins on my workstation
#   (no SSDs).
# - Automatically creates and uses Kiwi's boot image cache, which saves about 1
#   min with tmpfs.
# - Had added support for Kiwi's image cache, but this had negligible speed-up
#   in my setup so removed the code to reduce complexity.
# - Had added auto-detection of pigz (parallel gzip), but this also had
#   negligible speed-up in my setup so excluded it too.
#
# Author: James Tan <jatan@suse.de>
# ========================================================================

# Size in MB
TMPFS_SIZE=3600

BOOT_CACHE_DIR=/var/cache/kiwi/bootimage
OUTPUT_DIR=image
TMP_DIR="${KIWI_BUILD_TMP_DIR:-build-tmp}"
CLEAN=

function ensure_root {
  if [ $USER != 'root' ]; then
    echo "Please run as root."
    exit 1
  fi
}

function check_kiwi {
  ensure_root
  kiwi=`command -v kiwi`
  if [ $? -ne 0 ]; then
    echo "Kiwi is required but not found on your system."
    echo "Run the following command to install kiwi:"
    echo
    echo "  zypper install kiwi kiwi-tools kiwi-desc-vmxboot"
    echo
    exit 1
  fi
}

function clean_up {
  local exit_code=$?

  # Only clean up once
  [ "$CLEAN" ] && return
  CLEAN=true

  echo "** Cleaning up"

  # Save the image and log files
  mkdir -p $OUTPUT_DIR
  mv $TMP_DIR/{build/image-root.log,*.qcow2} $OUTPUT_DIR 2>/dev/null || true
  local USER=`stat -c %U .`
  local GROUP=`stat -c %G .`
  chown -R $USER.$GROUP $OUTPUT_DIR

  # Save initrd as boot image cache
  rsync -ql $TMP_DIR/initrd-* $BOOT_CACHE_DIR 2>/dev/null || true

  umount -l $TMP_DIR || true
  rm -rf $TMP_DIR || true

  exit $exit_code
}

function create_tmpfs {
  mkdir -p $TMP_DIR

  local RAM_THRESHOLD=$((TMPFS_SIZE-500))
  local free_ram=`free -m | awk '/^-\/\+ buffers/{print $4}'`
  echo "** Free RAM: $free_ram MB, tmpfs threshold: $RAM_THRESHOLD MB"
  if [ "$free_ram" -lt "$RAM_THRESHOLD" ]; then
    echo "** tmpfs: Skipping, insufficient free RAM"
    return
  fi

  if df $TMP_DIR | egrep -q "^tmpfs"; then
    echo "** tmpfs: Reusing existing mount point"
  else
    echo "** tmpfs: Creating new volume ($TMPFS_SIZE MB)"
    mount -t tmpfs -o size=${TMPFS_SIZE}M,noatime tmpfs $TMP_DIR
  fi
}

function run_kiwi {
  create_tmpfs
  mkdir -p $BOOT_CACHE_DIR
  echo "** Running kiwi (with $BOOT_CACHE_DIR as boot image cache)"
  time $kiwi --build source/ -d $TMP_DIR --prebuiltbootimage $BOOT_CACHE_DIR
  echo "** Appliance created successfully!"
}

check_kiwi
trap clean_up SIGINT SIGTERM EXIT
run_kiwi

exit 0
