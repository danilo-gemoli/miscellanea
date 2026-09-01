#!/bin/bash

set -euo pipefail

cat /etc/fstab \
 | awk 'BEGIN { PRINT_LINE = 0 } PRINT_LINE == 1 { print } /# Custom entries/ { PRINT_LINE = 1 }' \
 | {
    IFS= read -r record
    src=$(awk '{ print $1 }' <<<"$record")
    dst=$(awk '{ print $2 }' <<<"$record")
    file_type=$(stat --format='%F' "$src")

    case "$file_type" in
      "regular file")
        if [ ! -f "$dst" ]; then
            base=$(dirname "$dst")
            [ ! -d "$base" ] && mkdir -p "$base" 
            touch "$dst"
        fi
        ;;

      "directory")
        [ ! -d "$dst" ] && mkdir -p "$dst" 
        ;;

      *)
        echo "file type $file_type of $src is unsupported" 
        exit 1
        ;;
    esac
 }