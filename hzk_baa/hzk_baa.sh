#!/usr/bin/env bash

# AUTOMATIC EXECUTION IN THE TERMINAL:
# crontab -e
# 0 2 * * * /home/kali/Projects/hzk_baa/hzk_baa.sh [main_path] /var/backups

main () { # Define main function for script execution
	backup_start=$(date +%Y%m%d_%H%M%S) # date: Get system date and time. # +%Y%m%d_%H%M%S: Format as YearMonthDay_HourMinuteSecond. # backup_start: Save current timestamp for start.

	echo "Backup and Archiving Automation by HZK" # echo: Print text to the terminal. # "Backup...": The welcome message for users.
	
	if [ -n "$1" ] && [ -n "$2" ]; then # if: Start conditional logic block. # -n "$1": Check if first argument exists. # &&: Logical AND operator for conditions. # -n "$2": Check if second argument exists.
    		main_path="$1" # main_path: Variable for the source path. # $1: First argument passed to script.
    		backup_path="$2" # backup_path: Variable for the destination path. # $2: Second argument passed to script.
	else # else: Fallback if condition is false.
    		read -p "Enter the path to the directory to be backed up: " main_path # read: Prompt user for input string. # -p: Display text prompt before input. # main_path: Save user input to variable.
    		read -p "Enter the path to the destination directory where the backups will be stored: " backup_path # read: Prompt user for input string. # -p: Display text prompt before input. # backup_path: Save user input to variable.
	fi # fi: Close the argument condition block.
	
	if [ -z "${main_path}" ] || [ -z "${backup_path}" ]; then # if: Start the empty path check. # -z "${main_path}": Check if source path is empty. # ||: Logical OR operator for conditions. # -z "${backup_path}": Check if target path is empty.
		echo "Error: The directory path cannot be left blank" >&2 # echo: Print the empty error text. # >&2: Redirect error message to stderr.
		exit 1 # exit: Terminate current script execution immediately. # 1: Return error status code one.
	fi # fi: Close empty path check block.
	

	if [ ! -d "${main_path}" ]; then # if: Start source validation condition block. # ! -d "${main_path}": Check if source is not directory.
		echo "Error: Main path not found. The process has been cancelled." >&2 # echo: Print missing source directory error. # >&2: Redirect error message to stderr.
		exit 1 # exit: Terminate current script execution immediately. # 1: Return error status code one.
	fi # fi: Close source validation condition block.

	if [ ! -d "${backup_path}" ]; then # if: Start target validation condition block. # ! -d "${backup_path}": Check if target is not directory.
		echo "Backup path not found, creating..." # echo: Print directory creation status message.
		mkdir -p "$backup_path" # mkdir: Create a new directory path. # -p: Create parent directories if missing. # "$backup_path": Targeted path for the backup.
	fi # fi: Close target validation condition block.

	backup_file="${backup_path}/backup_baa_${backup_start}.tar.gz" # backup_file: Variable for final archive path. # "${backup_path}...": Build filename using path and timestamp.
	tar -czvf "${backup_file}" "${main_path}" # tar: Archive utility command for Linux. # -czvf: Compress using gzip and verbose. # "${backup_file}": The output target archive file. # "${main_path}": The input source folder path.
	
	success_code=$? # success_code: Variable for command execution status. # $?: Capture exit code of tar.
	
	log_path="${backup_path}/backup.log" # log_path: Variable for log file path. # "${backup_path}...": Append backup.log to target path.
	
	backup_end=$(date +%Y%m%d_%H%M%S) # date: Get system date and time. # +%Y%m%d_%H%M%S: Format as YearMonthDay_HourMinuteSecond. # backup_end: Save current timestamp for end.
	
	if [ "${success_code}" -eq 0 ]; then # if: Start status evaluation condition block. # "${success_code}" -eq 0?: Verify if tar exit code equals zero.
		echo "BACKUP AND ARCHIVING AUTOMATION BY HZK LOG FILE" >> "${log_path}" # echo: Print log file header line. # >>: Append output to target file. # "${log_path}": Destination path for log entries.
		echo "" >> "${log_path}" # echo "": Print an empty newline character. # >>: Append output to target file. # "${log_path}": Destination path for log entries.
		echo "Start Time: ${backup_start}" >> "${log_path}" # echo: Print the backup start timestamp. # >>: Append output to target file. # "${log_path}": Destination path for log entries.
		echo "Archived Directory: ${main_path}" >> "${log_path}" # echo: Print targeted source folder path. # >>: Append output to target file. # "${log_path}": Destination path for log entries.
		echo "End Time: ${backup_end}" >> "${log_path}" # echo: Print the backup completion timestamp. # >>: Append output to target file. # "${log_path}": Destination path for log entries.
		echo "Backup successful" # echo: Print success confirmation to screen.
	else # else: Fallback if tar exit code non-zero.
		echo "Error: Backup failed" >&2 # echo: Print backup execution failure text. # >&2: Redirect error message to stderr.
	fi # fi: Close status evaluation condition block.
	
	find "${backup_path}" -type f -name "*.tar.gz" -mtime +7 -exec rm "{}" \; # find: Search utility command for Linux. # "${backup_path}": The directory folder to search. # -type f: Look only for file objects. # -name "*.tar.gz": Filter files matching archive file extension. # -mtime +7: Select files older than seven days. # -exec rm "{}" \;: Execute delete command on found files.
} # End of main function block
main "$@" # main: Invoke the script main function. # "$@": Pass all script parameters to function.
