#!/bin/bash

admin_ip="$1"

sed -i "s,192.168.124.10,${admin_ip},g" /root/*-cloud*.yaml
