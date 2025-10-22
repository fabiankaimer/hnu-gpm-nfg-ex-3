#!/bin/sh
printf '\033c\033]0;%s\a' hnu-gpm-nfg-ex2
base_path="$(dirname "$(realpath "$0")")"
"$base_path/hnu-gpm-nfg-ex2.x86_64" "$@"
