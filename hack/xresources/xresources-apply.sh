#!/bin/bash

function apply() {
    DISPLAY=':0' XAUTHORITY='/run/user/1000/gdm/Xauthority' xrdb /home/dgemoli/.Xresources
    echo "/home/dgemoli/.Xresources applied - exit code $?"
}

echo "starting xresources-apply"

dbus-monitor --system "type='signal',path=/org/freedesktop/UPower" | 
grep --line-buffered LidIsClosed |
while read line; do
    # TODO: find a way not to rely on sleep.
    # When the lid is opened/closed the main screen transitions from being
    # active, total black and then active again. xrdb command must be issued
    # after that transition takes place in order to be effective.
    # The easiest way I found to achieve it is just to wait n seconds and 
    # the run the command.
    # 4s seems to be a good tradeoff.
    sleep 4s
    apply
done
