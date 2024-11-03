#!/bin/sh

# Verificar se o Alacritty e o Zellij estão instalados
if ! command -v alacritty >/dev/null 2>&1; then
  notify-send "Erro: Alacritty não encontrado. Por favor, instale o Alacritty."
  exit 1
fi

if ! command -v zellij >/dev/null 2>&1; then
  notify-send "Erro: Zellij não encontrado. Por favor, instale o Zellij."
  exit 1
fi

# Obter os caminhos completos para Alacritty e Zellij
ALACRITTY_PATH=$(command -v alacritty)
ZELLIJ_PATH=$(command -v zellij)

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)

if [ -z "$1" ]; then
  PWD=$(pwd)
elif [ -d "$1" ]; then
  PWD=$(cd "$1" && pwd)
elif [ -f "$1" ]; then
  FILE_PATH=$(readlink -f "$1")
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

CONFIG_DIR="$SCRIPT_DIR/configs"

$ALACRITTY_PATH \
  --working-directory "$PWD" \
  --class Alacritty \
  --config-file "$CONFIG_DIR/alacritty.toml" \
  -o "env.ZELLIJ_CONFIG_FILE=\"$CONFIG_DIR/zellij.kdl\"" \
  -e "$ZELLIJ_PATH" \
  --layout="$LAYOUT_FILE" &

# Create .nv_history file in $HOME if it doesn't exist
NV_HISTORY_FILE="$HOME/.nv_history"
[ ! -f "$NV_HISTORY_FILE" ] && touch "$NV_HISTORY_FILE"

# Store PWD, FILE_PATH, and timestamp in .nv_history
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
if [ -n "$FILE_PATH" ]; then
  echo "$TIMESTAMP | PWD=$PWD | FILE_PATH=$FILE_PATH" >>"$NV_HISTORY_FILE"
else
  echo "$TIMESTAMP | PWD=$PWD" >>"$NV_HISTORY_FILE"
fi
