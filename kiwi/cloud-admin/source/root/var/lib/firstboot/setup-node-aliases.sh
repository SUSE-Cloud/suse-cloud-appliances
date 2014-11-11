#!/bin/bash

nodes=( $( knife node list ) )
aliases=(
    admin # DUMMY, only used for alignment
    controller1
    controller2
    compute1
    compute2
)

error_count=0
for (( i=1; i < ${#nodes[@]}; i++ )); do
    node="${nodes[$i]}"
    alias="${aliases[$i]}"
    echo "Setting alias $alias for $node ... "
    if ! crowbar machines rename $node $alias; then
        error_count=$(( error_count + 1 ))
    fi
done

exit $error_count
