#!/usr/bin/bash
CONTAINER_NAME=vaultwarden
BACKUP_DIR=$HOME/vaultwarden_backups
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
DATA_DIR=/opt/vaultwarden
BUCKET_NAME=stuff
mkdir -p $BACKUP_DIR

echo "Backing up Vaultwarden data..."

echo "Stopping Vaultwarden container..."
# Stop container to ensure data consistency
docker stop $CONTAINER_NAME

echo "Backing up SQLite database..."
# Backup SQLite database
sqlite3 $DATA_DIR/db.sqlite3 ".backup '$BACKUP_DIR/vaultwarden-db-$TIMESTAMP.sqlite3'"

echo "Creating archive of Vaultwarden data..."
# Create archive of entire data directory, excluding cache and temp files
tar --exclude="$DATA_DIR/icon_cache" --exclude="$DATA_DIR/tmp" --zstd -cvf $BACKUP_DIR/vaultwarden-data-$TIMESTAMP.tar.zst $DATA_DIR/

echo "Uploading backups to R2 bucket..."
rclone copy $BACKUP_DIR/vaultwarden-data-$TIMESTAMP.tar.zst r2:$BUCKET_NAME/backups/$TIMESTAMP
rclone copy $BACKUP_DIR/vaultwarden-db-$TIMESTAMP.sqlite3 r2:$BUCKET_NAME/backups/$TIMESTAMP

rm -rf $BACKUP_DIR

# Restart container
docker start $CONTAINER_NAME
