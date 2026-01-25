#!/bin/bash

if [ ! -d /mnt/old ]; then
	sudo mkdir -p /mnt/old
fi

sudo mount 192.168.1.5:/ /mnt/old
