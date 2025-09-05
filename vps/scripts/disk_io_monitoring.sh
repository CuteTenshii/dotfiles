#!/usr/bin/bash
LOGFILE=/home/tenshii/disk-io-monitor.log
THRESHOLD_MB=100 # Trigger alert if container reads more than 100MB/s

while true; do
  TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

  # Capture stats once per loop
  sudo docker stats --no-stream --format "{{.Name}} {{.BlockIO}}" | while read line; do
    NAME=$(echo $line | awk '{print $1}')
    READWRITE=$(echo $line | awk '{print $2}')
    READ=$(echo $READWRITE | cut -d'/' -f1 | tr -d '[:alpha:]')
    UNIT=$(echo $READWRITE | cut -d'/' -f1 | grep -o '[A-Za-z]*')

    # Normalize to MB
    if [[ $UNIT == "GB" ]]; then
      READ=$(echo "$READ * 1024" | bc)
    elif [[ $UNIT == "kB" ]]; then
      READ=$(echo "$READ / 1024" | bc -l)
    fi

    if (( $(echo "$READ > $THRESHOLD_MB" | bc -l) )); then
      echo "$TIMESTAMP High disk I/O detected in $NAME: $READWRITE" | tee -a "$LOGFILE"
    fi
  done

  # Rotate log if >10MB
  if [ -f "$LOGFILE" ] && [ $(stat -c%s "$LOGFILE") -gt $((10*1024*1024)) ]; then
    mv "$LOGFILE" "$LOGFILE.$(date +%s).old"
    touch "$LOGFILE"
  fi

  sleep 5
done
