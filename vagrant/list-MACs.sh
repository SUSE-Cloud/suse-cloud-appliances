#!/bin/bash

if [ -z "$VAGRANT_ADMIN_NODE" ]; then
    nodes=( )
else
    nodes=( admin )
fi

nodes+=( controller1 controller2 compute1 )

for node in "${nodes[@]}"; do
    echo -n "$node: "
    vagrant ssh $node -c 'ip link show eth1 | awk "/ether/ {print \$2}"' -- -q
done
