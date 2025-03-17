#!/bin/bash

log_info() {
    local message=$1
    echo "==> RUNNER INFO: $message"
}

log_warn() {
    local message=$1
    echo "==> RUNNER WARN: $message"
}

log_crit() {
    local message=$1
    echo "==> RUNNER CRITICAL: $message"
}