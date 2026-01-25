#!/bin/bash

DEV=enp0s31f6

sudo ip link set $DEV up
sudo ip addr flush dev $DEV
sudo ip addr add 10.10.10.2/30 dev $DEV
sudo ip neigh flush all
sudo ethtool -s $DEV speed 1000 duplex full autoneg off
sudo systemctl disable firewalld
