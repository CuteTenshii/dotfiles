#!/usr/bin/bash
set -euo pipefail

CONTAINER_NAME=db
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
DATABASES=$(sudo docker exec -i $CONTAINER_NAME psql -U postgres -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;")
BACKUP_DIR="./pg_backups_$TIMESTAMP"

mkdir -p "$BACKUP_DIR"

for db in $DATABASES; do
    BACKUP_FILE="${BACKUP_DIR}/${db}_backup_${TIMESTAMP}.sql"

    echo "Backing up database: $db"
    sudo docker exec -t "$CONTAINER_NAME" pg_dump -U postgres "$db" > "$BACKUP_FILE"

    echo "Dropping and recreating database: $db"
    sudo docker exec -t "$CONTAINER_NAME" dropdb -U postgres "$db"
    sudo docker exec -t "$CONTAINER_NAME" createdb -U postgres "$db" --locale=C --template=template0

    echo "Restoring database: $db"
    sudo docker cp "$BACKUP_FILE" "$CONTAINER_NAME:/tmp/backup.sql"
    sudo docker exec -t "$CONTAINER_NAME" psql -U postgres -d "$db" -f /tmp/backup.sql
    sudo docker exec -t "$CONTAINER_NAME" rm /tmp/backup.sql

    echo "✅ Finished $db"
done