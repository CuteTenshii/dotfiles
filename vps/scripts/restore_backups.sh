#!/usr/bin/bash
BUCKET_NAME="stuff"
PLAUSIBLE_DB_CONTAINER=plausible-plausible_db-1
# this check is to see if we are only restoring files and not dbs
ONLY_RESTORE_FILES=false
if [[ "$1" == "true" ]]; then
    ONLY_RESTORE_FILES=true
fi

# Find the most recent backup
MOST_RECENT_BACKUP=$(rclone lsf "r2:$BUCKET_NAME/backups" --format "p" | sort | tail -n 1)
BACKUP_FILES=$(rclone lsf "r2:$BUCKET_NAME/backups/$MOST_RECENT_BACKUP" --format "p")

if [ "$ONLY_RESTORE_FILES" != "true" ]; then
    SQL_ARCHIVES=$(echo $BACKUP_FILES | tr ' ' '\n' | grep "\.sql\.zst$")
    for SQL_ARCHIVE in $SQL_ARCHIVES; do
        echo "Restoring database from $SQL_ARCHIVE"
        # Extract SQL archive
        rclone copyto "r2:$BUCKET_NAME/backups/$MOST_RECENT_BACKUP/$SQL_ARCHIVE" /tmp/$SQL_ARCHIVE

        echo "Extracting SQL archive"
        SQL_FILENAME="/tmp/${SQL_ARCHIVE%.zst}"
        zstd -fd /tmp/$SQL_ARCHIVE -o $SQL_FILENAME
        rm -f /tmp/$SQL_ARCHIVE

        echo "Restoring database from $SQL_FILENAME"
        # Restore the full database
        if [[ $SQL_ARCHIVE == "plausible*" ]]; then
            sudo docker exec -i $PLAUSIBLE_DB_CONTAINER psql -U postgres -d postgres < $SQL_FILENAME
            rm -f $SQL_FILENAME
            continue
        fi
        sudo docker exec -i db psql -U postgres -d postgres < $SQL_FILENAME
        rm -f $SQL_FILENAME
    done
fi

VAULTWARDEN_ARCHIVE=$(echo $BACKUP_FILES | tr ' ' '\n' | grep "^vaultwarden-data")
if [ -n "$VAULTWARDEN_ARCHIVE" ]; then
    if [[ ! -d /opt/vaultwarden ]]; then
        echo "Creating /opt/vaultwarden directory"
        sudo mkdir -p /opt/vaultwarden
    fi

    echo "Restoring Vaultwarden data from $VAULTWARDEN_ARCHIVE"
    rclone copyto "r2:$BUCKET_NAME/backups/$MOST_RECENT_BACKUP/$VAULTWARDEN_ARCHIVE" /tmp/$VAULTWARDEN_ARCHIVE

    echo "Extracting Vaultwarden archive"
    # Extract Vaultwarden archive
    tar -I zstd -xf /tmp/$VAULTWARDEN_ARCHIVE -C /opt/vaultwarden

    rm -f /tmp/$VAULTWARDEN_ARCHIVE
fi

NPM_ARCHIVE=$(echo $BACKUP_FILES | tr ' ' '\n' | grep "^npm_backup_")
if [ -n "$NPM_ARCHIVE" ]; then
    if [[ ! -d /opt/npm ]]; then
        echo "Creating /opt/npm directory"
        sudo mkdir -p /opt/npm
    fi

    echo "Restoring NPM data from $NPM_ARCHIVE"
    rclone copyto "r2:$BUCKET_NAME/backups/$MOST_RECENT_BACKUP/$NPM_ARCHIVE" /tmp/$NPM_ARCHIVE

    echo "Extracting NPM archive"
    # Extract NPM archive
    tar -I zstd -xf /tmp/$NPM_ARCHIVE -C /opt/npm

    rm -f /tmp/$NPM_ARCHIVE
fi

NPM_SSL_ARCHIVE=$(echo $BACKUP_FILES | tr ' ' '\n' | grep "^npm_ssl_backup_")
if [ -n "$NPM_SSL_ARCHIVE" ]; then
    if [[ ! -d /opt/ssl ]]; then
        echo "Creating /opt/ssl directory"
        sudo mkdir -p /opt/ssl
    fi

    echo "Restoring NPM SSL data from $NPM_SSL_ARCHIVE"
    rclone copyto "r2:$BUCKET_NAME/backups/$MOST_RECENT_BACKUP/$NPM_SSL_ARCHIVE" /tmp/$NPM_SSL_ARCHIVE

    echo "Extracting NPM SSL archive"
    # Extract NPM SSL archive
    tar -I zstd -xf /tmp/$NPM_SSL_ARCHIVE -C /opt/ssl

    rm -f /tmp/$NPM_SSL_ARCHIVE
fi