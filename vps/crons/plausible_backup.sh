#!/usr/bin/bash
BUCKET_NAME=stuff
PLAUSIBLE_CONTAINER=plausible-plausible-1
PLAUSIBLE_DB_CONTAINER=plausible-plausible_db-1
PLAUSIBLE_EVENTS_CONTAINER=plausible-plausible_events_db-1
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
DB_FILENAME=/tmp/plausible_backup_$TIMESTAMP.sql.zst
EVENTS_DATA_FILENAME=/tmp/plausible_events_backup_$TIMESTAMP.tar.zst

echo "Stopping container to ensure no data corruption"
# Stop container to ensure no data corruption
sudo docker stop $PLAUSIBLE_CONTAINER

echo "Creating database backup"
sudo docker exec -i $PLAUSIBLE_DB_CONTAINER pg_dump -U postgres plausible_db | zstd -T0 -19 -o $DB_FILENAME

echo "Creating events database backup"
tar --zstd -cvf $EVENTS_DATA_FILENAME -C /opt/plausible_event-data .

echo "Uploading backup to remote storage"
rclone copy $DB_FILENAME r2:$BUCKET_NAME/backups/$TIMESTAMP
if [ $? -eq 0 ]; then
  echo "Backup uploaded successfully"
else
  echo "Failed to upload backup"
fi

rclone copy $EVENTS_DATA_FILENAME r2:$BUCKET_NAME/backups/$TIMESTAMP
if [ $? -eq 0 ]; then
  echo "Events backup uploaded successfully"
else
  echo "Failed to upload events backup"
fi

echo "Starting container back up"
sudo docker start $PLAUSIBLE_CONTAINER