# Xterm

## Fonts
List available fonts:
```sh
$ fc-list | cut -f2 -d: | sort -u
```
the names from the resulting list might be set into the `.Xresources` file as:
```sh
XTerm*vt100.faceName:           xft:${FONT_NAME}:...
```
