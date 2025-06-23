#!/bin/bash

SCRIPT_DIR=$(dirname -- "$0")

source "$SCRIPT_DIR/alerter.sh"
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/game-interactor.sh"
source "$SCRIPT_DIR/runner-config.sh"

MEM_HIGH=0
MEM_CRIT=0

start() {
    start_server

    alert_server_start
    log_info "Server Startup, tmux session 'minecraft-server' started"
}

server_running() {
    tmux has-session -t minecraft-server 2>/dev/null
}

stop() {
    if server_running; then
        log_info "Stop signal received, server dedected as running, giving players 10 seconds grace period..."
        send_chat_server_msg "The server is about to stop/shutdown, get to a safe place!" "Stopping in 10sec..."
        send_actionbar_title "Server Stopping in 10sec"

        sleep 10

        log_info "Grace period over, kicking everyone..."
        kick_all "Stop command was issued, if you wish to know why contact the server owners."

        sleep 3
        touch "${SCRIPT_DIR}/stopsig"
        stop_server
        alert_server_stop
    else
        log_warn "Stop signal receieved but the server was already offline, is this a mistake?"
    fi

    exit 0
}

memory_check() {
    local system_used_mem
    system_used_mem=$(free -m | awk 'NR==2{printf "%d", $3*100/$2 }')

    if [[ $system_used_mem -ge 95 ]]; then
        log_crit "System memory usage exceeding safe operational parameters: ${system_used_mem}"
        send_chat_server_msg "Memory usage exceeds safe operational prarameters, attempting graceful restart before imminent crash." "Automatic restart in 5 seconds!!"
        send_actionbar_title "Auto restart in 5sec, mem usage critical!"

        sleep 5
        kick_all "Memory usage exceeded safe operational parameters, the server is attempting to gracefully restart & recover. If this happens frequently, report it to the server admin."
        log_crit "Kick command issued for all players"

        sleep 1
        stop_server
        alert_server_stop_unplanned "System memory usage exceeded 97%, attempted graceful restart & recovery."

        sleep 3
        start
        MEM_HIGH=0
        MEM_CRIT=0
    elif [[ $system_used_mem -ge 90 ]]; then
        if [[ $MEM_CRIT -eq 0 ]]; then
            log_warn "Critical system memory usage: ${system_used_mem}"
            send_chat_server_msg "Critically high memory usage: ${system_used_mem}%" "memory intensive tasks include: terrain generation, having many chunks loaded at once, too many running complicated redstone farms, ..."

            MEM_CRIT=1
        fi
    elif [[ $system_used_mem -ge 80 ]]; then
        if [[ $MEM_HIGH -eq 0 ]]; then
            log_warn "High system memory usage: ${system_used_mem}"
            send_chat_server_msg "High server memory usage: ${system_used_mem}%" "If this happens frequently, contact the server admin."

            MEM_HIGH=1
        fi
    else
        if [[ $system_used_mem -lt 80 ]]; then
            if [[ $MEM_HIGH -eq 1 || $MEM_CRIT -eq 1 ]]; then
                log_info "System memory usage normalised: ${system_used_mem}"
                send_chat_msg "Memory usage normalised: ${system_used_mem}% :)" ""

                MEM_HIGH=0
                MEM_CRIT=0
            fi
        fi
    fi
}

check_network() {
    ping -c 4 1.1.1.1 &>/dev/null
    if [ $? -eq 0 ]; then
        nslookup $SERVER_ADDRESS >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            log_warn "DNS resolution not ready"
            return 1
        else
            log_info "network connection verified (pinged 1.1.1.1 & verified DNS resolution to self)"
            return 0
        fi
    fi

    ping -c 4 8.8.8.8 &>/dev/null
    if [ $? -eq 0 ]; then
        nslookup $SERVER_ADDRESS >/dev/null 2>&1
        if [[ $? -ne 0 ]]; then
            log_warn "DNS resolution not ready"
            return 1
        else
            log_info "network connection verified (pinged 8.8.8.8 & veried DNS resolution to self)"
            return 0
        fi
    fi

    log_info "network connection pending, retrying..."
    return 1
}

net_retries=0

case "$1" in
    start)
        until check_network; do
            if [[ $net_retries -ge 30 ]]; then
                log_crit "failed to verify network connection"
                exit 1
            fi
            net_retries=$((net_retries + 1))

            if [[ $net_retries -ge 20 ]]; then
                sleep 60
                log_info "Increase network check interval to 60sec for last 10 retries..."
            else
                sleep 5
            fi
        done

        start

        while server_running; do
            memory_check
            sleep 10
        done

        if [ -f "${SCRIPT_DIR}/stopsig" ]; then
            rm "${SCRIPT_DIR}/stopsig"
            log_info "serverstop dedected, exiting runner thread"
            exit 0
        fi
        ;;
    stop)
        stop
        ;;
    *)
        log_warn "invalid argument, provide 'start' or 'stop'"
        exit 2
        ;;
esac

log_crit "Server crashed, process exited"
alert_server_crash "Process exited"

exit 1
