#!/bin/sh

if pgrep -x "rofi" >/dev/null; then
  pkill rofi
  exit 0
fi

SCRIPT_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
ROFI_CONFIG="$SCRIPT_DIR/configs/rofi.rasi"
NV_HISTORY_FILE="$HOME/.nv_history"

SELECTION_LIST=$(awk -F '|' '{
  if ($3 ~ /FILE_PATH=/) {
    sub(/^ FILE_PATH=/, "", $3);
    print $3;
  } else {
    sub(/^ PWD=/, "", $2);
    print $2;
  }
}' "$NV_HISTORY_FILE" | tac | awk '!seen[$0]++')

while true; do
  SELECTION=$(echo "$SELECTION_LIST" | rofi -i -dmenu \
    -config "$ROFI_CONFIG" \
    -matching fuzzy)

  case "$?" in
  1) exit 0 ;; # Exit if no selection
  0)
    [ -z "$SELECTION" ] && continue
    SELECTION=$(echo "$SELECTION" | sed "s|^~|$HOME|")
    break
    ;;
  *) exit 0 ;;
  esac
done

# Run nv.sh with the selected or entered path
"$SCRIPT_DIR/nv.sh" "$SELECTION"
