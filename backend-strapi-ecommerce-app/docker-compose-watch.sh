#!/bin/bash

PREFIX=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    PREFIX=""
elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    # Sistem operasi Linux
    PREFIX="sudo"
else
    echo "Sistem operasi tidak didukung."
    exit 1
fi

# Clear Console
clear

# Import .env File
if [ -f .env ]; then
  echo ".env found!"
  source .env
else
  echo "Please Set .env First!"
  exit 1
fi
BACKUP_DATABASE="./database/backup.sql"

start() {
  $PREFIX docker-compose stop
  # Start Docker Compose
  $PREFIX docker-compose up -d

  # Install mariadb-client
  $PREFIX docker container exec $CONTAINER_NAME apt update -y
  $PREFIX docker container exec $CONTAINER_NAME apt install mariadb-client -y

  # Check Docker MariaDB is Connected
  while ! $PREFIX docker container exec $CONTAINER_NAME mariadb --user=$DATABASE_USERNAME --password=$DATABASE_PASSWORD --execute="SELECT 1"; do
    sleep 1
  done

  if [ -f $BACKUP_DATABASE ]; then
    # Import SQL
    echo "backup.sql is Found"
    echo "Importing MariaDB SQL..."

   $PREFIX docker container exec -i $CONTAINER_NAME mariadb --user=root --password=$DATABASE_ROOT_PASSWORD < $BACKUP_DATABASE

  fi

  echo "DATABASE is BEATING UP"
}

stop() {

  # Export SQL
  $PREFIX docker container exec $CONTAINER_NAME mariadb-dump --user=root --password=$DATABASE_ROOT_PASSWORD --lock-tables --all-databases > $BACKUP_DATABASE

  # Stop Docker Compose
  $PREFIX docker-compose stop
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac

exit 0
