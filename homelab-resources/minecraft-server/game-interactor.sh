#!/bin/bash

kick_all() {
    local reason="$1"
    tmux send-keys -t minecraft-server "/kick @a $reason" Enter
}

send_chat_server_msg() {
    local description="$1"
    local subtext="$2"

    tmux send-keys -t minecraft-server "/tellraw @p [\"\",{\"text\":\"!! SERVER INFO !!:\",\"bold\":true,\"color\":\"gold\",\"hoverEvent\":{\"action\":\"show_text\",\"contents\":[{\"text\":\"Information & alerts coming directly from the server.\",\"color\":\"white\"}]}},{\"text\":\"\\n$description\",\"color\":\"white\"},{\"text\":\"\\n$subtext\",\"italic\":true,\"color\":\"gray\"}]" Enter
}

send_actionbar_title() {
    local text="$1"
    tmux send-keys -t minecraft-server "/title @a actionbar {\"text\":\"$text\"}" Enter
}

start_server() {
    tmux new-session -d -s minecraft-server "/usr/bin/java -Xmx6G -Xms4G -jar /opt/minecraft/server.jar nogui"
}

stop_server() {
    tmux send-keys -t minecraft-server "/stop" Enter
}
