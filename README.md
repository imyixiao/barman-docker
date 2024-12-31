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


## Examples of usage

See the examples/ directory for examples of how to use this image.

 * ***streaming***: The remote database server streams its WAL logs to barman.
   This reduces the "Recovery Point Objective (RPO)" to nearly 0.  RPO is the
   "maximum amount of data you can afford to lose."<sup>[1](#barman_docs)</sup>
   This example also sets up  a weekly cron job to take incremental base backups
   using rsync.  This helps reduce the time that would be required to play back
   the WAL files in a disaster recovery situation.

Currently only streaming of WAL logs is supported.  Using postgres's
`archive_command` functionality is not supported at this time.

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
| /home/barman/.ssh/id_rsa | The private ssh key that barman will use to connect to remote host when recovery |

## Footnotes:

<a name='barman_docs'><sup>1</sup></a>: [Barman Documentation](http://docs.pgbarman.org/release/2.1/)
