## MariaDB master-slave replication with bin-logs
This uses binary logs names and positions to track replication, rather than
[Global Transaction Ids (GTID)](https://mariadb.com/kb/en/library/gtid/) which
was introduced in 10.0.2. The two main points listed as benifits of GTIDs are:
> 1. Easy to change a slave server to connect to and replicate from a different master server.
> 2. The state of the slave is recorded in a crash-safe way.

`db1` is the master, and `db2` is the slave.
