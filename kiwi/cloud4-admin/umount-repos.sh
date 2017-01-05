#!/bin/bash

mount | awk '/source\/root\/srv\/tftpboot/ {print $3}' | xargs -r sudo umount
