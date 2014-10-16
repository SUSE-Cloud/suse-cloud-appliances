#!/bin/bash

nodes=( $( knife node list | grep '^ *d' ) )
for node in "${nodes[@]}"; do
    alias=$( ssh -n $node cat .vagrant-guest-name 2>/dev/null )
    if [ -n "$alias" ]; then
        echo "Setting alias $alias for $node ... "
        crowbar machines rename $node $alias
    else
        echo "WARNING: couldn't retrieve /root/.vagrant-guest-name from $node" >&2
    fi
done
