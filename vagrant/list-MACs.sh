#!/bin/bash

for node in admin controller1 controller2 compute1; do
    echo -n "$node: "
    vagrant ssh $node -c 'ip link show eth1 | awk "/ether/ {print \$2}"' -- -q
done
