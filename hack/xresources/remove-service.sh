#!/bin/bash

systemd_units_dir="/etc/systemd/system"
service='xresources-fix.service'
systemctl_otps=''

systemctl ${systemctl_otps} stop "${service}"
systemctl ${systemctl_otps} disable "${service}"

echo "removing ${systemd_units_dir}/${service}"
rm "${systemd_units_dir}/${service}"

echo "reloading systemd"
systemctl ${systemctl_otps} daemon-reload

systemctl ${systemctl_otps} reset-failed
