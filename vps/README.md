some files and scripts used on my vps.

The `install.sh` script is used to set up the environment and install necessary packages on a fresh VPS.

## crons

Those files are run every day at midnight UTC.

- `vw_backup.sh`: A script to backup Vaultwarden data and upload it to an R2 bucket.
- `pg_backup.sh`: A script to backup PostgreSQL databases and upload them to an R2 bucket.

Those scripts compress the backups using zstd for efficient storage, and upload them to a Cloudflare R2 bucket.

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