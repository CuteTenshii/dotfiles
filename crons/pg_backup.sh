#!/usr/bin/bash
CONTAINER_NAME=db
BACKUP_DIR=$HOME/backups
BUCKET_NAME=stuff
mkdir -p $BACKUP_DIR
DATABASES=$(sudo docker exec -i $CONTAINER_NAME psql -U postgres -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;")

for db in $DATABASES; do
  BACKUP_FILE=${db}_backup_$(date +%F_%T).sql.gz

  echo "Backing up database: $db"

  # Dump the database and compress it
  docker exec -t $CONTAINER_NAME pg_dump -U postgres $db | gzip > $BACKUP_DIR/$BACKUP_FILE

  # Check for errors
  if [[ $? -ne 0 ]]; then
    echo "Error occurred while backing up database: $db"
    continue
  fi
  echo "Backup completed: $BACKUP_FILE"
  echo "Uploading backup to R2 bucket: $BACKUP_FILE"

  # Upload to R2 bucket using rclone
  rclone copy $BACKUP_DIR/$BACKUP_FILE r2:$BUCKET_NAME/backups/

  # Check for errors
  if [[ $? -ne 0 ]]; then
    echo "Error occurred while uploading backup: $BACKUP_FILE"
    continue
  fi
  echo "Upload completed: $BACKUP_FILE"
  echo ""

  # Delete the local backup file
  rm $BACKUP_DIR/$BACKUP_FILE
done
