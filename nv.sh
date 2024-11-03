#!/bin/sh

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)

if [ -z "$1" ]; then
  PWD=$(pwd)
elif [ -d "$1" ]; then
  PWD="$1"
elif [ -f "$1" ]; then
  FILE_PATH="$1"
  PWD=$(dirname "$FILE_PATH")
else
  echo "Error: Invalid path provided."
  exit 1
fi

LAYOUT_FILE="/tmp/layout_$(date +%s%N).kdl"

cat <<EOL >"$LAYOUT_FILE"
layout {
  pane command="nvim" {
$([ -n "$FILE_PATH" ] && echo "    args \"$FILE_PATH\"")
    borderless true
    close_on_exit true
  }
}
EOL

alacritty \
  --working-directory "$PWD" \
  --class Alacritty \
  --config-file "$SCRIPT_DIR/alacritty/alacritty.toml" \
  -o "env.ZELLIJ_CONFIG_FILE=\"$SCRIPT_DIR/zellij/config.kdl\"" \
  -e zellij \
  --layout="$LAYOUT_FILE" &
