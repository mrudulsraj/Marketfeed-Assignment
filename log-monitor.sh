#!/bin/bash

LOG_FILE="/assignment/log/sample.log"
SCRIPT_LOG="/assignment/script/script.log"

log_message() {
    local log_level="$1"
    local message="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$log_level] $message" >> "$SCRIPT_LOG"
}
handle_signals() {
    log_message "INFO" "Received signal. Exiting."
    exit 0
}
analyze_log_file() {
	    declare -A log_level_counts  
	    declare -A error_messages  

	    if [ ! -f "$LOG_FILE" ]; then
		log_message "ERROR" "Log file '$LOG_FILE' not found. Exiting."
		exit 1
	    fi

	    trap handle_signals SIGINT
	    tail -n0 -F "$LOG_FILE" | while IFS= read -r line; do
		log_level=$(echo "$line" | awk '{print $3}')
		error_message=$(echo "$line" | awk -F ']' '{print $2}')

		((log_level_counts["$log_level"]++))

		if [[ "$log_level" == "[ERROR" ]]; then
		    ((error_messages["$error_message"]++))
		fi

		if (( ${#log_level_counts[@]} % 10 == 0 )); then
		    print_log_level_summary "${log_level_counts[@]}"
		fi

		if (( ${#error_messages[@]} % 10 == 0 )); then
		    print_error_messages "${error_messages[@]}"
		fi
	    done
	}
print_log_level_summary() {
    log_message "INFO" "Log level counts summary:"
    for level in "${!log_level_counts[@]}"; do
        log_message "INFO" "$level: ${log_level_counts["$level"]}"
    done
    log_message "INFO" "-------------------------------------"
}

print_error_messages() {
    log_message "INFO" "Top error messages:"
    IFS=$'\n' sorted_errors=($(sort -nrk2 <<< "${@}" | head -n 5))
    for error_line in "${sorted_errors[@]}"; do
        error_message=$(echo "$error_line" | awk '{print $1}')
        error_count=$(echo "$error_line" | awk '{print $2}')
        log_message "INFO" "$error_message: $error_count"
    done
    log_message "INFO" "-------------------------------------"
}

main() {
    touch "$SCRIPT_LOG" || { echo "Error creating script log file '$SCRIPT_LOG'. Exiting."; exit 1; }

    log_message "INFO" "Script started."

    analyze_log_file

    log_message "INFO" "Script finished."
}

main
