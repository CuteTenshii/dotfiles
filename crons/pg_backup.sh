#!/bin/bash

# Import environment variables
. $HOME/infra/db.env

CONTAINER_NAME=db
BACKUP_DIR=$HOME/backups
BUCKET_NAME=femboy-stuff
DATABASES=$(docker exec -t $CONTAINER_NAME psql -U postgres -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;")

for db in $DATABASES; do
  BACKUP_FILE=${db}_backup_$(date +%F_%T).sql.gz

  # Dump the database and compress it
  docker exec -t $CONTAINER_NAME pg_dump -U postgres $db | gzip > $BACKUP_DIR/$BACKUP_FILE

  # Upload to R2 bucket using rclone
  rclone copy $BACKUP_DIR/$BACKUP_FILE r2:$BUCKET_NAME/path/to/backups/

  # Delete the local backup file
  rm $BACKUP_DIR/$BACKUP_FILE
done
