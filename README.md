# 🛡️ HZK Linux Automation & Security Bash Suite

A collection of lightweight, dependency-free Bash scripts designed for Linux system administration, security auditing, and network monitoring. Built using native Linux core utilities (`awk`, `grep`, `tar`, `ping`, `find`).

---

## 📋 Table of Contents
1. [Backup and Archiving Automation (`hzk_baa`)](#1-backup-and-archiving-automation-hzk_baa)
2. [Audit and Hardening Script (`hzk_ahs`)](#2-audit-and-hardening-script-hzk_ahs)
3. [Network Uptime Monitor (`hzk_num`)](#3-network-uptime-monitor-hzk_num)
4. [Installation & Permissions](#installation--permissions)
5. [Disclaimer](#disclaimer)

---

## 1. Backup and Archiving Automation (`hzk_baa`)

An automated backup utility that compresses target directories into timestamped `.tar.gz` archives, logs execution metrics, and enforces a 7-day retention policy.

### ✨ Key Features
* **Flexible Execution:** Supports both CLI arguments (ideal for `crontab`) and interactive user prompts.
* **Compressed Archiving:** Creates timestamped archives (`backup_baa_YYYYMMDD_HHMMSS.tar.gz`) using `tar` and `gzip`.
* **Automated Retention:** Automatically purges backup archives older than 7 days using `find -mtime +7`.
* **Execution Logging:** Records start time, target directory, and completion time to `backup.log`.

### 🚀 Usage
**Interactive Mode:**
```bash
./hzk_baa.sh
```

**CLI / Automated Mode (Crontab):**
```bash
./hzk_baa.sh /path/to/source /path/to/destination
```

**Example Crontab Entry (Runs daily at 02:00 AM):**
```cron
0 2 * * * /home/kali/Projects/hzk_baa/hzk_baa.sh /var/www/html /var/backups
```

---

## 2. Audit and Hardening Script (`hzk_ahs`)

A Linux security auditing tool that inspects critical system configurations, user privileges, and authentication policies to detect potential vulnerabilities.

### ✨ Key Features
* **Privilege Verification:** Enforces `ROOT` (`EUID 0`) execution to safely inspect restricted files like `/etc/shadow` and `/etc/sudoers`.
* **Account & UID Auditing:** Lists system users from `/etc/passwd`, flags multiple `UID 0` (root) accounts, and detects passwordless accounts in `/etc/shadow`.
* **Sudoers Risk Analysis:** Scans `/etc/sudoers` for excessive `ALL` privileges and dangerous binaries/shell escapes (`bash`, `.sh`, `vim`, `nano`, `more`).
* **System Policy Checks:** Verifies if the system `UMASK` is set to a strict `077` in `/etc/login.defs` and checks for password complexity enforcement (`/etc/security/pwquality.conf`).
* **Dual Output:** Displays color-coded terminal alerts (`[SAFE]`, `[WARNING]`, `[CRITICAL RISK]`) while saving a clean report to `security_audit_YYYYMMDD.txt`.

### 🚀 Usage
```bash
sudo ./hzk_ahs.sh
```

---

## 3. Network Uptime Monitor (`hzk_num`)

A continuous ICMP network monitoring tool that tracks host availability, packet loss, and round-trip latency across a list of target IPs and domains.

### ✨ Key Features
* **Batch Target Scanning:** Reads IP addresses and domain names dynamically from `targets.txt` while ignoring empty lines.
* **ICMP Metric Extraction:** Uses `ping -c 3 -W 2` paired with `grep` and `awk` to parse exact **packet loss (%)** and **average RTT (ms)**.
* **Real-Time Alerting & Logging:** Highlights `[UP]` (green) and `[DOWN]` (red) statuses in the terminal and appends timestamped entries to `uptime.log`.
* **Continuous Monitoring:** Runs in a configurable periodic loop (default: 10 seconds) until stopped with `Ctrl+C`.

### 🚀 Usage
1. Add your target IPs or domains to `targets.txt` (one per line):
   ```text
   8.8.8.8
   1.1.1.1
   github.com
   192.168.1.1
   ```
2. Start the monitor:
   ```bash
   ./monitor.sh
   ```
3. *(Optional)* Follow logs live in a separate terminal:
   ```bash
   tail -f uptime.log
   ```

---

## ⚙️ Installation & Permissions

Clone the repository and grant execution permissions to the scripts:

```bash
git clone https://github.com
cd hzk-bash-suite
chmod +x hzk_baa/hzk_baa.sh hzk_ahs/hzk_ahs.sh hzk_num/monitor.sh
```

---

## ⚠️ Disclaimer
These scripts are developed for educational purposes, system administration, and authorized security auditing. Always test backup and security scripts in a controlled environment before deploying them to production systems.
