FROM mariadb:10.0
COPY db.cnf /etc/mysql/conf.d/db.cnf
COPY db2.cnf /etc/mysql/conf.d/db2.cnf
