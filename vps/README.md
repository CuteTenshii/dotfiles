Some files and scripts that I use on my VPS.

## `crons`

Those files are run every day at midnight UTC.

- `vaultwarden_backup.sh`: A script to backup Vaultwarden data and upload it to an R2 bucket.
- `pg_backup.sh`: A script to backup PostgreSQL databases and upload them to an R2 bucket.
- `plausible_backup.sh`: A script to backup Plausible Analytics data and upload it to an R2 bucket.
- `npm_backup.sh`: A script to backup Nginx Proxy Manager data + SSL certificates, and upload it to an R2 bucket.

Those scripts compress the backups using zstd for efficient storage, and upload them to a Cloudflare R2 bucket.

## `scripts`

- `backup_all.sh`: A script to run all backup scripts at once. Those scripts are in the `crons` folder.
- `restore_backups.sh`: A script to restore backups from the R2 bucket to the VPS.
- `install.sh`: A script to set up the environment and install necessary packages on a fresh VPS.
- `disk_io_monitoring.sh`: A script to continuously monitor disk I/O and log when it exceeds a certain threshold.

## Packages used

### Base packages

`git`, `htop`, `eza`, `ca-certificates`, `curl`, `wget`, `nano`, `fail2ban`

### fail2ban

Fail2ban automatically detects and blocks brute-force attacks by monitoring log files and banning suspicious IPs. I use it primarily to protect SSH access on my VPS, and to automatically report brute-force IPs to AbuseIPDB for community threat sharing.

### Used for backups

- `cron`: For scheduling backup tasks
- `zstd`: Fast compression algorithm used for compressing backup files
- `rclone`: Used to upload backups to a Cloudflare R2 bucket
- `sqlite3`: Vaultwarden uses SQLite for its database