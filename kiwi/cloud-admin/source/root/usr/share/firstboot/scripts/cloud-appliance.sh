#!/bin/bash

# install man, as it's convenient -- not done when building the appliance to
# keep it smaller; but skipping if we're on livecd to not abuse disk space
if [ ! -d /livecd ]; then
    zypper --non-interactive install man
fi

# automatically do the inital setup; we don't want to connect to an external
# database with the appliance
systemctl start apache2
systemctl start crowbar-init
/usr/lib/firstboot/wait-for-crowbar-init
crowbarctl database create
