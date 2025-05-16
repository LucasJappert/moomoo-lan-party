#!/bin/sh
echo -ne '\033c\033]0;moomoo-lan-party\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Moomoo LAN Party.x86_64" "$@"
