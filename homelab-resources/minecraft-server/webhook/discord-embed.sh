#!/bin/bash

SCRIPT_DIR=$(dirname -- "$0")
source "$SCRIPT_DIR/send.sh"

urls_file="$SCRIPT_DIR/urls/discord-embed"

if [ ! -f "$urls_file" ]; then
    echo "Error: File $urls_file not found."
    exit 1
fi

source "$SCRIPT_DIR/../runner-config.sh"
ICON_URL="https://eu.mc-api.net/v3/server/favicon/$SERVER_ADDRESS"

discord_urls=()
while IFS= read -r line || [ -n "$line" ]; do
    discord_urls+=("$line")
done < "$urls_file"

FIELDS="[]"

if [[ $# -gt 3 ]]; then
    # Validate the JSON for fields
    if ! echo "$4" | jq empty > /dev/null 2>&1; then
        echo "Error: Invalid JSON format for fields"
        exit 1
    fi
    FIELDS="$4"
fi

payload="{
    \"content\": null,
    \"embeds\": [
        {
            \"title\": \"$1\",
            \"description\": \"$2\",
            \"color\": $3,
            \"author\": {
                \"name\": \"$SERVER_ADDRESS\",
                \"icon_url\": \"$ICON_URL\"
            },
            \"fields\": $FIELDS
        }
    ],
    \"attachments\": []
}"

for url in "${discord_urls[@]}"; do
    send_webhook "$payload" "$url"
done
