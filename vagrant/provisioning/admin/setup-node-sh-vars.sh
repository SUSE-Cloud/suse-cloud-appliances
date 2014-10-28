#!/bin/bash

mv /tmp/node-sh-vars /root/bin

cat <<EOF >>/root/.bash_profile
if [ -e /tmp/.crowbar-nodes-roles.cache ]; then
  source /tmp/.crowbar-nodes-roles.cache
fi
EOF
