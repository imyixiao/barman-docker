#!/bin/bash

echo "Generating Barman configurations"
cat /etc/barman.conf.template | envsubst > /etc/barman.conf
cat /etc/barman/barman.d/pg.conf.template | envsubst > /etc/barman/barman.d/${DB_HOST}.conf

echo "Generating additional cron schedules (barman cron happens every minute already)"
echo "${BARMAN_BACKUP_SCHEDULE} barman /usr/bin/barman switch-wal --force all" >> /etc/cron.d/barman
echo "${BARMAN_BACKUP_SCHEDULE} barman /usr/bin/barman backup all --wait" >> /etc/cron.d/barman

exec "$@"


