#!/bin/bash

# install man, as it's convenient -- not done when building the appliance to
# keep it smaller
zypper --non-interactive install man

# use UTC as timezone, working around broken timezone support for SLE 12 in
# kiwi...
timedatectl set-timezone UTC
