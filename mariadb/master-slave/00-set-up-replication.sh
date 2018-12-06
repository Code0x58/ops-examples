#!/bin/bash
# XXX: would be good if there was proper quoting, would be simplest
#  to use Python
source "$(realpath "$(dirname "$(realpath $0)")")/../../common.sh"

doc << DOC
== Master → Slave set up ==

Make sure that the replication user has the correct privilages.

DOC
run db1 mysql -e "GRANT REPLICATION SLAVE ON *.* TO replication_user"
doc << DOC

Set everything needed in CHANGE MASTER except log-file and position to
prepare it for recieving a dump later:

DOC
run db2 mysql -e "
  STOP SLAVE;
  CHANGE MASTER TO
    MASTER_HOST='db1',
    MASTER_USER='replication_user',
    MASTER_PASSWORD='',
    MASTER_PORT=3306,
    MASTER_CONNECT_RETRY=10"

doc << DOC

Use mysqldump to create a dump, it will set MASTER_LOG_FILE and
MASTER_LOG_POS, delete old slaved databases, and start slaving when the dump
is imported.

DOC
dumpfile="/tmp/dump-$(date +"%Y-%m-%dT%H:%M:%S").sql"
run db1 mysqldump \
    --all-databases \
    --master-data=1 \
    --apply-slave-statements \
    --add-drop-database \> $dumpfile
doc << DOC

As of MariaDB 5.3 it is possible to add --single-transaction to perform a
non-blocking dump (altough there is a brief lock at the start).

Once this is done, the dump can be imported into the slave machine:

DOC

run db2 mysql \< $dumpfile

doc << DOC

The position of the master can be checked:

DOC
run db1 mysql -e "SHOW MASTER STATUS"

doc << DOC

The status of the slave can be checked:

DOC
run db2 mysql -e "SHOW SLAVE STATUS\G"

doc << DOC

When the database is written to, the master log position will change, and the
slave will follow. In this case the master isn't being written to, so to
prove it works (note replication isn't instantanious so this may fail):

DOC
run db2 mysql -e "SHOW DATABASES LIKE 'now%'"
run db1 mysql -e "CREATE DATABASE now_you_see_me"
sleep 1
run db2 mysql -e "SHOW DATABASES LIKE 'now%'"

doc << DOC

There is a container running adminer which is linked to the two database
containers, it can be acessed at http://127.0.0.1:8080/ and from there
you can log into root:@db1 and root:@db2.
DOC
