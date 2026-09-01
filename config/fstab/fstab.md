# Setup

Add the following entries to `/etc/fstab`:

```sh
/home/dgemoli/dev/src/github.com/danilo-gemoli/miscellanea/config/bash/.bashrc.d /home/dgemoli/.bashrc.d none defaults,bind,nofail 0 0
/home/dgemoli/dev/src/github.com/danilo-gemoli/miscellanea/dotfiles/.Xresources /home/dgemoli/.Xresources none defaults,bind,nofail 0 0
/home/dgemoli/dev/src/github.com/danilo-gemoli/miscellanea/dotfiles/.vimrc /home/dgemoli/.vimrc none defaults,bind,nofail 0 0
/home/dgemoli/dev/src/github.com/danilo-gemoli/miscellanea/dotfiles/.tmux.conf /home/dgemoli/.tmux.conf none defaults,bind,nofail 0 0
/home/dgemoli/dev/src/github.com/danilo-gemoli/miscellanea/hack /home/dgemoli/dev/hack none defaults,bind,nofail 0 0
/home/dgemoli/dev/src/github.com/danilo-gemoli/miscellanea/dotfiles/.gitconfig /home/dgemoli/.gitconfig none defaults,bind,nofail 0 0
```

Since it's a bind mount, make sure that destination files and dirs exist.

Make the config effective on systemd:
```sh
systemctl daemon-reload
```