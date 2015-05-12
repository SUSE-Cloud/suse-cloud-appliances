#!/bin/bash

mv /var/lib/firstboot/node-sh-vars /root/bin

cat <<EOF >>/root/.bash_profile
if [ -e /tmp/.crowbar-nodes-roles.cache ]; then
  source /tmp/.crowbar-nodes-roles.cache
fi
EOF
