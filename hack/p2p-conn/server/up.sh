#!/bin/bash

DEV=enp0s20f0u2u1u2

sudo ip link set $DEV up
sudo ip addr flush dev $DEV
sudo ip addr add 10.10.10.1/30 dev $DEV
sudo ip neigh flush all
sudo ethtool -s $DEV speed 1000 duplex full autoneg off
sudo systemctl disable firewalld
