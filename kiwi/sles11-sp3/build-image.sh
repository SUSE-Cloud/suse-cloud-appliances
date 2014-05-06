#!/bin/bash -e

# ========================================================================
# Script for building SUSE Cloud admin appliance
#
# Requires Kiwi (http://opensuse.github.io/kiwi/).
#
# Build performance:
# - Automatically builds in RAM (tmpfs) if there's enough free memory. This
#   brings the build time down significantly, especially without SSDs.
# - Automatically creates and uses Kiwi's boot image cache, which saves about 1
#   min with tmpfs.
# - Had added support for Kiwi's image cache, but this had negligible speed-up
#   in my setup so removed the code to reduce complexity.
# - Had added auto-detection of pigz (parallel gzip), but this also had
#   negligible speed-up in my setup so excluded it too.
#
# ========================================================================

TMPFS_SIZE=6500

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

function warn {
  echo >&2 -e "$*"
}

function unclean_exit {
  local exit_code=$?

  warn "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  warn "\nWARNING: premature termination!"
  if df $TMP_DIR | egrep -q "^tmpfs"; then
      warn "\nLeaving $TMP_DIR mounted."
      warn "You must umount it yourself in order to free RAM."
  fi
  warn "\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"

  exit $exit_code
}

function clean_up {
  echo >&2 -e "$*"

  # Only clean up once
  [ "$CLEAN" ] && return
  CLEAN=true

  echo "** Cleaning up"

  # Save the image and log files
  mkdir -p $OUTPUT_DIR
  mv $TMP_DIR/{build/image-root.log,*.qcow2,*.vmdk} $OUTPUT_DIR 2>/dev/null || true
  local USER=`stat -c %U .`
  local GROUP=`stat -c %G .`
  chown -R $USER.$GROUP $OUTPUT_DIR

  # Save initrd as boot image cache
  rsync -ql $TMP_DIR/initrd-* $BOOT_CACHE_DIR 2>/dev/null || true

  if df $TMP_DIR | egrep -q "^tmpfs"; then
      umount $TMP_DIR
  fi
  rm -rf $TMP_DIR
}

function create_tmpfs {
  mkdir -p $TMP_DIR

  local ram_required=$((TMPFS_SIZE))
  local free_ram=`free -m | awk '/^-\/\+ buffers/{print $4}'`
  echo "** Free RAM: $free_ram MB; RAM required: $ram_required MB"
  if [ "$free_ram" -lt "$ram_required" ]; then
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
  time $kiwi --build source/ -d $TMP_DIR --prebuiltbootimage $BOOT_CACHE_DIR "$@"
  echo "** Appliance created successfully!"
}

check_kiwi
trap unclean_exit SIGINT SIGTERM
run_kiwi "$@"
clean_up

exit 0
