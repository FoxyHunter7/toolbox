#!/bin/bash

SCRIPT_DIR=$(dirname -- "$0")
SENDERS=("$SCRIPT_DIR/webhook/discord-embed.sh")

# Decimal Colours
GREEN=65280
YELLOW=16776960
ORANGE=16753920
RED=16711680
WHITE=16777215

send() {
    local title="$1"
    local description="$2"
    local decimal_colour="$3"

    for sender in "${SENDERS[@]}"; do
        "$sender" "$title" "$description" "$decimal_colour"
    done
}

alert_server_start() {
    send "Server Starting" "The server should be online any second now." "$GREEN"
}

alert_server_stop() {
    send "Server Stopped" "The server has been stopped." "$YELLOW"
}

alert_server_stop_unplanned() {
    local cause="$1"
    send "Server Stopped" "$cause" "$ORANGE"
}

alert_server_crash() {
    local reason="$1"
    send "Server Crashed" "$reason" "$RED"
}
