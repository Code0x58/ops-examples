FROM mariadb:10.0
COPY db.cnf /etc/mysql/conf.d/db.cnf
COPY db1.cnf /etc/mysql/conf.d/db1.cnf
