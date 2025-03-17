#!/bin/bash

send_webhook() {
    local payload="$1"
    local url="$2"

    if [ -z "$url" ]; then
        echo "Error: Webhook URL is empty or not found"
        exit 1
    fi

    curl -s -H "Content-Type: application/json" -d "$payload" "$url" > /dev/null
}