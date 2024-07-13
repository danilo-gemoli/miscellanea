## Prevent external screen to go black when the laptop lid is closed
```sh
$ sudo sed -i -E 's/^#?(HandleLidSwitch=).+/\1ignore/' /etc/systemd/logind.conf
$ sudo sed -i -E 's/^#?(IgnoreLid=).+/\1true/' /etc/UPower/UPower.conf
$ reboot
```
