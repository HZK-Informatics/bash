#!/usr/bin/env bash

TARGET_FILE="$HOME/Desktop/Projects/hzk_num/targets.txt" # TARGET_FILE: Set path to target hosts list. # $HOME: Current user home directory path.
LOG_FILE="$HOME/Desktop/Projects/hzk_num/uptime.log" # LOG_FILE: Set path to output log file. # $HOME: Current user home directory path.

GREEN="\e[32m" # GREEN: Set green color code variable. # \e[32m: ANSI escape code for green text.
RED="\e[31m" # RED: Set red color code variable. # \e[31m: ANSI escape code for red text.
NC="\e[0m" # NC: Set reset color code variable. # \e[0m: ANSI escape code to reset color.

main () { # Define main function for host checking.
    echo "Network Uptime Monitor by HZK" # echo: Print script welcome banner to terminal. # "Network...": Application title text for users.
    
    if [[ ! -f "$TARGET_FILE" ]]; then # if: Start target file existence check block. # ! -f "$TARGET_FILE": Check if file does not exist.
        echo "Error: $TARGET_FILE not found!" # echo: Print missing target file error message.
        exit 1 # exit: Terminate current script execution immediately. # 1: Return general error status code one.
    fi # fi: Close target file existence check block.

    while IFS= read -r host || [[ -n "$host" ]]; do # while: Start loop reading target file lines. # IFS=: Preserve leading and trailing whitespace characters. # read: Read single line into host variable. # -r: Disable backslash escape character interpretation. # ||: Logical OR operator for loop condition. # -n "$host": Check if host string is non-empty.
        [[ -z "$host" || "$host" =~ ^[[:space:]]*# ]] && continue # -z "$host": Check if host line is empty. # ||: Logical OR operator for skip conditions. # =~: Match string against regular expression pattern. # ^[[:space:]]*#: Match lines starting with optional spaces/hash. # &&: Logical AND operator for short-circuiting. # continue: Skip current iteration to next line.
        
        ping_output=$(ping -c 3 -W 2 "$host" 2>&1) # ping: Send ICMP echo request packets. # -c 3: Stop after sending three ping packets. # -W 2: Set two-second timeout per packet. # "$host": Target IP address or domain name. # 2>&1: Redirect standard error to standard output.
        exit_code=$? # exit_code: Store ping command execution status. # $?: Capture exit code of previous command.
        DATE=$(date "+%Y-%m-%d %H:%M:%S") # date: Get current system date and time. # "+%Y-%m-%d %H:%M:%S": Format timestamp as Year-Month-Day Hour:Minute:Second. # DATE: Save formatted timestamp string to variable.
        if [[ $exit_code -eq 0 ]]; then # if: Start ping success evaluation condition block. # -eq 0: Check if exit code equals zero.
            packet_loss=$(echo "$ping_output" | grep -oE '[0-9]+% packet loss' | awk '{print $1}') # grep: Search text using regular expression pattern. # -o: Print only matched part of line. # -E: Enable extended regular expression syntax. # awk: Process matched text into structured columns. # {print $1}: Print first column containing loss percentage.
            avg_rtt=$(echo "$ping_output" | grep "rtt min/avg/max" | awk -F'/' '{print $5}') # grep: Filter summary line containing latency metrics. # awk: Split summary line into separate fields. # -F'/': Set forward slash as field delimiter. # {print $5}: Print fifth field representing average RTT.
            log_msg="[$DATE] [UP] $host - Loss: $packet_loss - Avg RTT: ${avg_rtt} ms" # log_msg: Format online status log message string.
            echo -e "${GREEN}${log_msg}${NC}" # echo: Print colored online status to terminal. # -e: Enable interpretation of backslash escape sequences.
            echo "$log_msg" >> "$LOG_FILE" # echo: Output plain text online status message. # >>: Append output to target log file. # "$LOG_FILE": Destination path for uptime log entries.
        else # else: Fallback if ping command returned non-zero.
            log_msg="[$DATE] [DOWN] $host - Host Unreachable" # log_msg: Format offline status log message string.
            echo -e "${RED}${log_msg}${NC}" # echo: Print colored offline status to terminal. # -e: Enable interpretation of backslash escape sequences.
            echo "$log_msg" >> "$LOG_FILE" # echo: Output plain text offline status message. # >>: Append output to target log file. # "$LOG_FILE": Destination path for uptime log entries.
        fi # fi: Close ping status evaluation condition block.
    done < "$TARGET_FILE" # done: Close while file reading loop block. # < "$TARGET_FILE": Redirect target file as loop input.
} # End of main function block.

next_scan () { # Define periodic scanning loop function.
    echo "Network Uptime Monitor started. Press [CTRL+C] to stop." # echo: Print startup instructions and exit shortcut.
    while true; do # while: Start infinite loop for continuous scanning. # true: Return always-true exit status code zero.
        echo "----------------------------------------" # echo: Print visual separator line between scans.
        main # main: Invoke main function to check hosts.
        echo "Waiting 10 seconds for next scan..." # echo: Display wait countdown message to terminal. # You can set the wait time for the next scan
        sleep 10 # sleep: Pause script execution for specified duration. # 10: Wait for ten seconds before continuing. # You can set the wait time for the next scan
    done # done: Close infinite monitoring loop block.
} # End of next_scan function block.
next_scan "$@" # next_scan: Invoke periodic scanning loop function. # "$@": Pass all script arguments to function.
