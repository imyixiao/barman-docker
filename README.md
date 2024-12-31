# docker-barman

The repo clones https://hub.docker.com/r/tbeadle/postgres/

This repo contains files used to build a [docker](https://www.docker.com) image
for running [BaRMan](https://github.com/2ndquadrant-it/barman), the "Backup and
Recovery Manager for PostgreSQL."

It is easily used in conjunction with the `tbeadle/postgres:<version>-barman`
images at https://hub.docker.com/r/tbeadle/postgres/.

## Getting the image

`docker-compose pull`

## Building the image

If you would like to build the image yourself, simply run:

`docker-compose build`

## Running the image

Running the image can be as simple as

`docker-compose up`

but you will likely want to create your own `docker-compose.yml` file to define
volumes that will be mounted for persistent data.  See the ***Environment
variables*** section below.


## Environment variables

The following environment variables may be set when starting the container:

| Name                               | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| ----                               | -----------                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| BARMAN_LOG_DIR                     | The location where log files can be stored.  For example, a cron job can be set up to take regular full backups and that can send its logs here.  Defaults to `/var/log/barman`.
| BARMAN_DATA_DIR                     | The location where data files can be stored.  Defaults to `/var/lib/barman`.                                                                                                
| BARMAN_CRON_SCHEDULE               | `* * * * *`, barman cron running scheduel
| BARMAN_BACKUP_SCHEDULE             | `0 4 * * *`, barman backup running schedule
| BARMAN_LOG_LEVEL                   | `INFO`, barman log level
| DB_HOST                            | `pg`, postgres host name
| DB_PORT                            | `5432`, postgres port
| DB_SUPERUSER                       | `postgres`, superuser username
| DB_SUPERUSER_PASSWORD              | `postgres`, superuser password
| DB_SUPERUSER_DATABASE              | `postgres`, superuser database
| DB_REPLICATION_USER                | `standby`, replication username
| DB_REPLICATION_PASSWORD            | `standby`, replication user password
| DB_SLOT_NAME                       | `barman`, postgres replication slot name for barman
| DB_BACKUP_METHOD                   | `postgres`, barman backup method, see barman backup
| RETENTION_POLICY                   | `RECOVERY WINDOW of 3 MONTHS` A backup retention policy is a user-defined policy that determines how long backups and related archive logs (Write Ahead Log segments) need to be retained for recovery procedures.

## Volumes

| Path                     | Description                                                                      |
|--------------------------|----------------------------------------------------------------------------------|
| BARMAN_DATA_DIR |  The location where data files can be stored.  Defaults to `/var/lib/barman`. |

## CRON JOBS
1. the `barman cron` will run on every minite to executes WAL archiving operations concurrently on a server basis, and this also enforces retention policies
2. the `barman backup` will run on `BARMAN_BACKUP_SCHEDULE` to take a full backup (base backup) of a given server.

## How to Recover a Master Cluster?
follow [Barman Documentation](https://docs.pgbarman.org/release/2.1/#recover)
1.  run Remote recovery allow Barman to execute the copy on a remote server, using the provided command to connect to the remote host. (this requires ssh setup, TBD)
2. Start a new postgres cluster with backup data

## Footnotes:

<a name='barman_docs'><sup>1</sup></a>: [Barman Documentation](http://docs.pgbarman.org/release/2.1/)
