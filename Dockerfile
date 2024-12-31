FROM debian:bullseye

# Install postgresql-16
RUN apt update && apt install -y wget gnupg2
RUN bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' \
	&& (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -)
RUN apt update && apt install -y --no-install-recommends postgresql-16

# Install barman and other packages
RUN apt-get update \
	&& apt-get -y install python3 \
		python3-pip \
		barman \
		barman-cli \
		gettext-base \
		cron

# Set up some defaults for file/directory locations used in entrypoint.sh.
ENV \
	BARMAN_CRON_SRC=/private/cron.d \
	BARMAN_DATA_DIR=/var/lib/barman \
	BARMAN_LOG_DIR=/var/log/barman \
	BARMAN_SSH_KEY_DIR=/private/ssh \
    BARMAN_CRON_SCHEDULE="* * * * *" \
    BARMAN_BACKUP_SCHEDULE="30 2 1 * *" \
    BARMAN_LOG_LEVEL=DEBUG \
    DB_HOST=host.docker.internal \
    DB_PORT=5432 \
    DB_SUPERUSER=barman \
    DB_SUPERUSER_PASSWORD=postgres \
    DB_SUPERUSER_DATABASE=postgres \
    DB_REPLICATION_USER=streaming_barman \
    DB_REPLICATION_PASSWORD=postgres \
    DB_SLOT_NAME=barman \
    DB_BACKUP_METHOD=postgres \
    RETENTION_POLICY="RECOVERY WINDOW of 3 MONTHS" 
VOLUME ${BARMAN_DATA_DIR}

# COPY install_barman.sh /tmp/
# RUN /tmp/install_barman.sh && rm /tmp/install_barman.sh
COPY barman.conf.template /etc/barman.conf.template
COPY pg.conf.template /etc/barman/barman.d/pg.conf.template

# # Install the entrypoint script.  It will set up ssh-related things and then run
# # the CMD which, by default, starts cron.  The 'barman -q cron' job will get
# # pg_receivexlog running.  Cron may also have jobs installed to run
# # 'barman backup' periodically.
COPY entrypoint.sh /
ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["cron", "-L", "4",  "-f"]
WORKDIR ${BARMAN_DATA_DIR}

