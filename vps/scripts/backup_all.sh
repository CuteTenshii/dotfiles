#!/usr/bin/bash
CRONS_PATH=../crons

sudo $CRONS_PATH/npm_backup.sh
sudo $CRONS_PATH/vaultwarden_backup.sh
sudo $CRONS_PATH/plausible_backup.sh
sudo $CRONS_PATH/pg_backup.sh