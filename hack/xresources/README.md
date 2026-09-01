## HowTo
Install the service
```sh
    make install
```

Remove the service
```sh
    make remove
```

## Lid
Lid state can be also checked at:
```sh
cat /proc/acpi/button/lid/LID/state
```

## Systemd docs
- [What is Systemd](https://www.digitalocean.com/community/tutorials/what-is-systemd)
- [Unit files](https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files)
- [systemctl](https://www.digitalocean.com/community/tutorials/how-to-use-systemctl-to-manage-systemd-services-and-units)
- [journalctl](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs)


## Gnome autostart
Gnome adheres to XDG autostart.
- [XDG autostart](https://wiki.archlinux.org/title/XDG_Autostart) standard.
- [Desktop entry spec](https://specifications.freedesktop.org/desktop-entry-spec/latest/)

wip: https://specifications.freedesktop.org/desktop-entry-spec/latest/ar01s07.html

## Autostarting
[Autostarting](https://wiki.archlinux.org/title/Autostarting#On_desktop_environment_startup)
