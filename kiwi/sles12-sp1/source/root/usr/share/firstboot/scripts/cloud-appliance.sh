#!/bin/bash

# install man, as it's convenient -- not done when building the appliance to
# keep it smaller; but skipping if we're on livecd to not abuse disk space
if [ ! -d /livecd ]; then
    zypper --non-interactive install man
fi
