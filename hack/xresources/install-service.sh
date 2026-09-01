#!/bin/bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
systemd_units_dir="/etc/systemd/system"
service='xresources-fix.service'
systemctl_otps=''

echo "copying ${script_dir}/${service} into ${systemd_units_dir}/"
cp "${script_dir}/${service}" "${systemd_units_dir}/"

echo "reloading systemd"
systemctl ${systemctl_otps} daemon-reload

echo "enabling ${service}"
systemctl ${systemctl_otps} enable "${service}"

echo -n "${service} status: "
systemctl ${systemctl_otps} is-enabled "${service}"

echo "starting ${service}"
systemctl ${systemctl_otps} start "${service}"
