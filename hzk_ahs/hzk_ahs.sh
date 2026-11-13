#!/usr/bin/env bash

main () { # Define main function for script execution.
	DATE=$(date +%Y%m%d) # date: Get current year month day. # DATE: Save formatted date to variable.
	SECURITY_AUDIT_PATH="/home/kali/Desktop/Projects/hzk_ahs/security_audit_${DATE}.txt" # Define file path for audit results. # SECURITY_AUDIT_PATH: Set output path variable.
	GREEN='\033[0;32m' # Set color code for safe text. # GREEN: Variable for green terminal text.
	YELLOW='\033[1;33m' # Set color code for info text. # YELLOW: Variable for yellow terminal text.
	RED='\033[0;31m' # Set color code for dangerous text. # RED: Variable for red terminal text.
	NC='\033[0m' # Set color code for normal text. # NC: Variable to reset terminal colors.

	echo "Audit and Hardening Script by HZK" # echo: Print script welcome title string. # "Audit...": Script title text for users.
	if [ "${EUID}" -ne "0" ]; then # if: Start root privilege check block. # -ne 0: Check if ID not equal zero.
		echo -e "${RED}[ERROR] Since this script scans critical system files, it must be run with ROOT privileges!${NC}" >&2 # echo: Print privilege error message text. # >&2: Redirect error stream to stderr.
		exit 1 # exit: Terminate current script execution immediately. # 1: Return failure status code one.
	fi # fi: Close root privilege check block.
	
	echo -e "${YELLOW}[INFO] Listing system users and home directories:${NC}" # echo: Print colored listing header message. # -e: Enable interpretation of backslash escapes.
	echo "[INFO] Listing system users and home directories:" >> "${SECURITY_AUDIT_PATH}" # echo: Print plain text header message. # >>: Append message text to log file.
	awk -F: '{print "User: " $1 " -> Home: " $6}' /etc/passwd # awk: Process colon separated text file entries. # /etc/passwd: Source path for user credentials.
	awk -F: '{print "User: " $1 " -> Home: " $6}' /etc/passwd >> "${SECURITY_AUDIT_PATH}" # awk: Extract users and home directories. # >>: Append user lists to log file.
	
	zero_uid_users=$(awk -F: '$3 == 0 {print $1}' /etc/passwd) # awk: Filter users having UID field zero. # zero_uid_users: Store accounts with zero UID.
	zero_uid_user_count=$(echo "${zero_uid_users}" | wc -w) # wc -w: Count words in input string. # zero_uid_user_count: Store total count value.
	if [ "${zero_uid_user_count}" -eq 1 ]; then # if: Check zero UID account count. # -eq 1: Compare total count with one.
		echo -e "${GREEN}[SAFE] Single 0 UID user found.${NC}" # echo: Print colored single root message. # -e: Enable interpretation of backslash escapes.
		echo "[SAFE] Single 0 UID user found." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean text safety message. # >>: Append safety message to log.
	else # else: Fallback if first condition is false. # else: Handle multiple root user scenario.
		echo -e "${RED}[CRITICAL RISK] Multiple 0 UID users found.${NC}" # echo: Print colored critical risk warning. # -e: Enable interpretation of backslash escapes.
		echo "[CRITICAL RISK] Multiple 0 UID users found." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean text risk warning. # >>: Append risk warning to log.
	fi # fi: Close zero UID check block.
	
	empty_passwd_users=$(awk -F: '$2 == "" {print $1}' /etc/shadow) # awk: Filter users with blank password. # empty_passwd_users: Store passwordless user names.
	if [ -z "${empty_passwd_users}" ]; then # if: Check if variable is empty. # -z: Verify string length is zero.
		echo -e "${GREEN}[SAFE] No empty password users found.${NC}" # echo: Print colored password safety message. # -e: Enable interpretation of backslash escapes.
		echo "[SAFE] No empty password users found." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean password safety message. # >>: Append password status to log.
	else # else: Fallback if first condition is false. # else: Handle existing empty password accounts.
		echo -e "${RED}[CRITICAL RISK] Empty password users found.${NC}" # echo: Print colored blank password warning. # -e: Enable interpretation of backslash escapes.
		echo "[CRITICAL RISK] Empty password users found." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean blank password warning. # >>: Append password warning to log.
	fi # fi: Close blank password check block.
	
	all_sudoers=$(grep -v '^#' /etc/sudoers | grep -i 'all') # grep: Extract lines containing ALL keyword. # all_sudoers: Store active sudo rules.
	all_sudoer_count=$(echo "${all_sudoers}" | wc -l) # wc -l: Count total lines of output. # all_sudoer_count: Store number of rules.
	if [ "${all_sudoer_count}" -le 5 ]; then # if: Verify number of ALL rules. # -le 5: Check if count <= five.
		echo -e "${GREEN}[SAFE] Sudoers ALL rules are within normal limits.${NC}" # echo: Print colored sudo safety message. # -e: Enable interpretation of backslash escapes.
		echo "[SAFE] Sudoers ALL rules are within normal limits." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean sudo safety message. # >>: Append sudo safety to log.
	else # else: Fallback if first condition is false. # else: Handle excessive sudo rules condition.
		echo -e "${RED}[WARNING] Excessive ALL privileges detected in sudoers!${NC}" # echo: Print colored excessive privileges warning. # -e: Enable interpretation of backslash escapes.
		echo "[WARNING] Excessive ALL privileges detected in sudoers!" >> "${SECURITY_AUDIT_PATH}" # echo: Print clean excessive privileges warning. # >>: Append privilege warning to log.
	fi # fi: Close sudoers rule count block.
	
	sudoer_risks=$(grep -v '^#' /etc/sudoers | grep -E 'bash|\.sh|more|nano|vim') # grep -E: Match multiple risk patterns. # sudoer_risks: Store dangerous configuration lines.
	if [ -z "${sudoer_risks}" ]; then # if: Check if risk variable empty. # -z: Verify string length is zero.
		echo -e "${GREEN}[SAFE] No risky binaries or shell escapes found in sudoers.${NC}" # echo: Print colored binary safety message. # -e: Enable interpretation of backslash escapes.
		echo "[SAFE] No risky binaries or shell escapes found in sudoers." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean binary safety message. # >>: Append binary safety to log.
	else # else: Fallback if first condition is false. # else: Handle dangerous binaries found case.
		echo -e "${RED}[WARNING] Dangerous binaries or shell escape paths found in sudoers!${NC}" # echo: Print colored shell escape warning. # -e: Enable interpretation of backslash escapes.
		echo "[WARNING] Dangerous binaries or shell escape paths found in sudoers!" >> "${SECURITY_AUDIT_PATH}" # echo: Print clean shell escape warning. # >>: Append escape warning to log.
	fi # fi: Close shell escape check block.
	
	system_umask=$(grep -E '^UMASK' /etc/login.defs | awk '{print $2}') # grep -E: Match active UMASK line. # system_umask: Store system configuration value.
	if [ "${system_umask}" = "077" ]; then # if: Check active UMASK configuration value. # = "077": Compare value with secure mask.
		echo -e "${GREEN}[SAFE] Your UMASK value is 077.${NC}" # echo: Print colored UMASK safety message. # -e: Enable interpretation of backslash escapes.
		echo "[SAFE] Your UMASK value is 077." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean UMASK safety message. # >>: Append UMASK status to log.
	else # else: Fallback if first condition is false. # else: Handle loose system mask configuration.
		echo -e "${RED}[WARNING] Your UMASK value is ${system_umask}${NC}" # echo: Print colored insecure mask warning. # -e: Enable interpretation of backslash escapes.
		echo "[WARNING] Your UMASK value is ${system_umask}" >> "${SECURITY_AUDIT_PATH}" # echo: Print clean insecure mask warning. # >>: Append mask warning to log.
	fi # fi: Close UMASK validation condition block.
	
	if [ -f /etc/security/pwquality.conf ]; then # if: Check if path exists now. # -f: Verify path is regular file.
		echo -e "${GREEN}[SAFE] Password policy file (pwquality.conf) exists.${NC}" # echo: Print colored file existence message. # -e: Enable interpretation of backslash escapes.
		echo "[SAFE] Password policy file (pwquality.conf) exists." >> "${SECURITY_AUDIT_PATH}" # echo: Print clean file existence message. # >>: Append file status to log.
	else # else: Fallback if first condition is false. # else: Handle missing configuration file case.
		echo -e "${RED}[WARNING] Password policy file (pwquality.conf) is missing!${NC}" # echo: Print colored missing file warning. # -e: Enable interpretation of backslash escapes.
		echo "[WARNING] Password policy file (pwquality.conf) is missing!" >> "${SECURITY_AUDIT_PATH}" # echo: Print clean missing file warning. # >>: Append missing file warning log.
	fi # fi: Close configuration file check block.
} # End of main function block.
main "$@" # main: Trigger the main execution flow. # $@: Pass arguments to main function.
