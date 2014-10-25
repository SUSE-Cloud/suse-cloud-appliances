#!/bin/bash

set -e

name="$1"
dst=/root/.vagrant-guest-name

echo "Writing '$name' to $dst"
echo "$1" > $dst
