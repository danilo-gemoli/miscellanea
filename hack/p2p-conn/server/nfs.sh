#!/bin/bash

#sudo mkdir -p /tmp/nfs_share
#sudo chown nobody:nogroup /tmp/nfs_share
#sudo chmod 777 /tmp/nfs_share

sudo systemctl start nfs-server

# One time only
if ! $(grep -qF '/home/dgemoli' /etc/exports); then
	sudo echo '/home/dgemoli 10.10.10.2(rw,sync,no_subtree_check,no_root_squash)' >>/etc/exports
fi

sudo exportfs -a
sudo systemctl restart nfs-server
sudo exportfs -v