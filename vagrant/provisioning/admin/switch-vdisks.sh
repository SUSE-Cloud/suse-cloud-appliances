#!/bin/bash

# FIXME: parametrize instead of doing this hack
DMIDECODE=/usr/sbin/dmidecode  # $PATH doesn't have /usr/sbin here (due to sudo?)
if $DMIDECODE | grep -q VirtualBox; then
  echo "On VirtualBox; using SCSI virtual disks ..."
elif $DMIDECODE | egrep -iq 'Bochs|QEMU'; then
  echo "On KVM; switching to virtio disks"
  sed -i 's,/dev/sd\([a-z]\),/dev/vd\1,' /root/*-cloud*.yaml
else
  echo "ERROR: Couldn't figure out what hypervisor we're on?!" >&2
  $DMIDECODE >&2
  exit 1
fi
