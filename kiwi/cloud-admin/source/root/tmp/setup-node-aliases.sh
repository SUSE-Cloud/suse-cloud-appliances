#!/bin/bash

nodes=( $( knife node list | grep '^ *d' ) )

error_count=0
for node in "${nodes[@]}"; do
    alias=$( ssh -n $node cat .vagrant-guest-name 2>/dev/null )
    if [ -n "$alias" ]; then
        echo "Setting alias $alias for $node ... "
        crowbar machines rename $node $alias
    else
        echo "WARNING: couldn't retrieve /root/.vagrant-guest-name from $node" >&2
        error_count=$(( error_count + 1 ))
    fi
done

exit $error_count
