#!/usr/bin/bash
CONTAINER_NAME=npm
BACKUP_DIR=$HOME/npm_backups
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
DATA_DIR=/opt/npm
SSL_DIR=/opt/ssl
BUCKET_NAME=stuff
mkdir -p $BACKUP_DIR

tar --exclude="./logs" --zstd -cvf $BACKUP_DIR/npm_backup_$TIMESTAMP.tar.zst -C $DATA_DIR .

tar --zstd -cvf $BACKUP_DIR/npm_ssl_backup_$TIMESTAMP.tar.zst -C $SSL_DIR .

rclone copy $BACKUP_DIR/npm_backup_$TIMESTAMP.tar.zst r2:$BUCKET_NAME/backups/$TIMESTAMP
rclone copy $BACKUP_DIR/npm_ssl_backup_$TIMESTAMP.tar.zst r2:$BUCKET_NAME/backups/$TIMESTAMP

rm -rf $BACKUP_DIR