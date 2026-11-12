#!/bin/bash

TARGET_FILE="$HOME/Desktop/Projects/hzk_num/targets.txt" # TARGET_FILE: store target list path | $HOME: user home directory
LOG_FILE="$HOME/Desktop/Projects/hzk_num/uptime.log" # LOG_FILE: store log file path | $HOME: user home directory

GREEN="\e[32m" # GREEN: define green color | \e[32m: ANSI green escape code
RED="\e[31m" # RED: define red color | \e[31m: ANSI red escape code
NC="\e[0m" # NC: define reset variable | \e[0m: ANSI reset escape code

main () { # main: define host checking function
    echo "Network Uptime Monitor by HZK" # echo: print application banner text
    
    if [[ ! -f "$TARGET_FILE" ]]; then # if: evaluate condition | !: negate result | -f: check regular file exists
        echo "Error: $TARGET_FILE not found!" # echo: print missing file error message
        exit 1 # exit: terminate script | 1: return general error status code
    fi # fi: close if conditional block

    while IFS= read -r host || [[ -n "$host" ]]; do # while: start loop | IFS=: preserve leading/trailing spaces | read: read line | -r: disable backslash escaping | -n: check non-empty string
        [[ -z "$host" ]] && continue # -z: check if string is empty | continue: skip current loop iteration
        echo "Checking: $host ..." # echo: display current scanning target
        
        ping_output=$(ping -c 3 -W 2 "$host" 2>&1) # ping: send ICMP packets | -c 3: send three packets | -W 2: set two-second timeout | 2>&1: redirect stderr to stdout
        exit_code=$? # exit_code: store status | $?: get last command exit code
        DATE=$(date "+%Y-%m-%d %H:%M:%S") # date: get system time | "+%Y-%m-%d %H:%M:%S": format date and time string
        if [[ $exit_code -eq 0 ]]; then # if: evaluate condition | -eq 0: check numeric equality to zero
            packet_loss=$(echo "$ping_output" | grep -oE '[0-9]+% packet loss' | awk '{print $1}') # grep: search text | -o: print only matched part | -E: enable extended regex | awk: process text | {print $1}: print first column
            avg_rtt=$(echo "$ping_output" | grep "rtt min/avg/max" | awk -F'/' '{print $5}') # grep: filter summary line | awk: split text | -F'/': set slash as delimiter | {print $5}: print fifth field
            log_msg="[$DATE] [UP] $host - Loss: $packet_loss - Avg RTT: ${avg_rtt} ms" # log_msg: format online status log string
            echo -e "${GREEN}${log_msg}${NC}" # echo: print text | -e: enable backslash escape interpretation
            echo "$log_msg" >> "$LOG_FILE" # echo: output log string | >>: append output to log file
        else # else: execute fallback branch on failure
            log_msg="[$DATE] [DOWN] $host - Host Unreachable" # log_msg: format offline status log string
            echo -e "${RED}${log_msg}${NC}" # echo: print text | -e: enable backslash escape interpretation
            echo "$log_msg" >> "$LOG_FILE" # echo: output log string | >>: append output to log file
        fi # fi: close if conditional block
    done < "$TARGET_FILE" # done: end while loop | <: redirect file as loop input
} # }: close main function block

next_scan () { # next_scan: define periodic loop function
    echo "Network Uptime Monitor started. Press [CTRL+C] to stop." # echo: print startup and exit instructions
    while true; do # while: start loop | true: return always-true exit status
        echo "----------------------------------------" # echo: print visual separator line
        main # main: execute host checking function
        echo "Waiting 10 seconds for next scan..." # echo: display wait countdown message - You can set the wait time for the next scan
        sleep 10 # sleep: pause execution | 10: wait for ten seconds - You can set the wait time for the next scan
    done # done: end infinite loop
} # }: close next_scan function block
next_scan "$@" # next_scan: call periodic function | "$@": pass all script arguments
