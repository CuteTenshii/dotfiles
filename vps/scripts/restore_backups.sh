#!/usr/bin/bash
BUCKET_NAME="stuff"

# Find the most recent backup
MOST_RECENT_BACKUP=$(rclone lsf "r2:$BUCKET_NAME/backups" --format "p" | sort | tail -n 1)
BACKUP_FILES=$(rclone lsf "r2:$BUCKET_NAME/backups/$MOST_RECENT_BACKUP" --format "p")

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
    sudo docker exec -i db psql -U postgres -d postgres < $SQL_FILENAME
    rm -f $SQL_FILENAME
done

VAULTWARDEN_ARCHIVE=$(echo $BACKUP_FILES | tr ' ' '\n' | grep "^vaultwarden-data")
if [ -n "$VAULTWARDEN_ARCHIVE" ]; then
    echo "Restoring Vaultwarden data from $VAULTWARDEN_ARCHIVE"
    rclone copyto "r2:$BUCKET_NAME/backups/$MOST_RECENT_BACKUP/$VAULTWARDEN_ARCHIVE" /tmp/$VAULTWARDEN_ARCHIVE

    echo "Extracting Vaultwarden archive"
    # Extract Vaultwarden archive in /, archives already includes the /opt/vaultwarden path
    tar -I zstd -xf /tmp/$VAULTWARDEN_ARCHIVE -C /

    rm -f /tmp/$VAULTWARDEN_ARCHIVE
fi