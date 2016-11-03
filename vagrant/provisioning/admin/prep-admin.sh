#!/bin/bash

set -e

cd /tmp

patch -d /opt/dell -p1 < barclamp-network-ignore-eth0.patch
rm -f barclamp-network-ignore-eth0.patch
patch -d /opt/dell -p1 < increase-SBD-timeout-30s.patch
rm -f increase-SBD-timeout-30s.patch
