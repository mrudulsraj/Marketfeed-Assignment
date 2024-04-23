#!/bin/bash

LOG_FILE="/assignment/log/sample.log"
SCRIPT_LOG="/assignment/script/script.log"

log_message() {
    local log_level="$1"
    local message="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$log_level] $message" >> "$SCRIPT_LOG"
}
