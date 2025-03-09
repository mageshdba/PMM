--Step 1 : 

Create a postgres user that can be used for monitoring. You could choose any username; pmm in the following command is just an example.


$ psql -c "CREATE USER pmm WITH ENCRYPTED PASSWORD 'Open@123'"

--Step 2 : 

Grant pg_monitor role to the pmm.

$ psql -c "GRANT pg_monitor to pmm"

--Step 3 : 

If you are not using localhost, but using the IP address of the PostgreSQL server while enabling monitoring in the next steps, you should ensure to add appropriate entries to enable connections from the IP and the pmm in the pg_hba.conf file.



$ echo "host    all             pmm        172.184.9.46/32        md5" >> $PGDATA/pg_hba.conf

$ psql -c "select pg_reload_conf()"
1
2
$ echo "host    all             pmm        173.11.9.83/32        md5" >> $PGDATA/pg_hba.conf
$ psql -c "select pg_reload_conf()"
In the above step, replace 192.168.80.20 with the appropriate PostgreSQL Server’s IP address.

--Step 4 : 

Validate whether you are able to connect as pmm to the postgres database from the postgres server itself.

# psql -h 172.184.1.48 -p 5665 -U pmm -d postgres
Password for user pmm: 

# psql -h 192.168.80.20 -p 5432 -U pmm -d postgres
Password for user pmm: 

 
postgres=>
Enabling PostgreSQL Monitoring with and without QAN (Query Analytics)
Using PMM, we can monitor several metrics in PostgreSQL such as database connections, locks, checkpoint stats, transactions, temp usage, etc. However, you could additionally enable Query Analytics to look at the query performance and understand the queries that need some tuning. Let us see how we can simply enable PostgreSQL monitoring with and without QAN.

==================

With QAN
With PMM2, there is an additional step needed to enable QAN. 
You should create a database with the same name as the monitoring user ( pmm here). And then, you should create the extension: pg_stat_statements in that database. This behavior is going to change on the next release so that you can avoid creating the database.

--Step 1 : 
Create the database with the same name as the monitoring user. Create the extension: pg_stat_statements in the database.


psql -c "CREATE DATABASE pmm"
psql  -h yappgresdb.cfzdwmybtrx8.ap-south-1.rds.amazonaws.com -p 5432 -Upostgres -c "CREATE DATABASE pmm"

psql -c -d pmm "CREATE EXTENSION pg_stat_statements"
psql  -h yappgresdb.cfzdwmybtrx8.ap-south-1.rds.amazonaws.com -p 5432 -Upostgres -c -d pmm "CREATE EXTENSION pg_stat_statements"
psql  -h yappgresdb.cfzdwmybtrx8.ap-south-1.rds.amazonaws.com -p 5432 -Upostgres pmm -c "CREATE EXTENSION pg_stat_statements"

--Step 2 : 
If shared_preload_libraries has not been set to pg_stat_statements, we need to set it and restart PostgreSQL.

Shell
$ psql -c "ALTER SYSTEM SET shared_preload_libraries TO 'pg_stat_statements'"
$ pg_ctl -D $PGDATA restart -mf
waiting for server to shut down.... done
server stopped
...
...
 done
server started

$ psql -c "ALTER SYSTEM SET shared_preload_libraries TO 'pg_stat_statements'"
$ pg_ctl -D $PGDATA restart -mf
waiting for server to shut down.... done
server stopped
...
...
 done
server started

--Step 3 :
In the previous steps, we used the flag: --query-source=none to disable QAN. In order to enable QAN, you could just remove this flag and use pmm-admin add postgresql without the flag.

Shell 
# pmm-admin add postgresql --username=pmm --password=secret postgres 172.122.8.34:5665
PostgreSQL Service added.
Service ID  : /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73
Service name: postgres

# pmm-admin add postgresql --username=pmmusr --password=secret postgres 172.28.7.4:5665
PostgreSQL Service added.
Service ID  : /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73
Service name: postgres

--Step 4 : 
Once the above step is completed, you could validate the same again using pmm-admin list. But this time, you should see an additional service: qan-postgresql-pgstatements-agent .

Shell
# pmm-admin list
Service type  Service name         Address and port  Service ID
PostgreSQL    postgres             192.168.80.20:5432 /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73

Agent type                  Status     Agent ID                                        Service ID
pmm-agent                   connected  /agent_id/13fd2e0a-a01a-4ac2-909a-cae533eba72e  
node_exporter               running    /agent_id/f6ba099c-b7ba-43dd-a3b3-f9d65394976d  
postgres_exporter           running    /agent_id/7039f7c4-1431-4518-9cbd-880c679513fb  /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73
qan-postgresql-pgstatements-agent running    /agent_id/7f0c2a30-6710-4191-9373-fec179726422  /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73

# pmm-admin list
Service type  Service name         Address and port  Service ID
PostgreSQL    postgres             192.168.80.20:5432 /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73
 
Agent type                  Status     Agent ID                                        Service ID
pmm-agent                   connected  /agent_id/13fd2e0a-a01a-4ac2-909a-cae533eba72e  
node_exporter               running    /agent_id/f6ba099c-b7ba-43dd-a3b3-f9d65394976d  
postgres_exporter           running    /agent_id/7039f7c4-1431-4518-9cbd-880c679513fb  /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73
qan-postgresql-pgstatements-agent running    /agent_id/7f0c2a30-6710-4191-9373-fec179726422  /service_id/24efa8b2-02c2-4a39-8543-d5fd54314f73
After this step, you can now see the Queries and their statistics captured on the Query Analytics Dashboard.

Meanwhile, have you tried Percona Distribution for PostgreSQL? It is a collection of finely-tested and implemented open source tools and extensions along with PostgreSQL 11, maintained by Percona. PMM works for both Community PostgreSQL and also the Percona Distribution for PostgreSQL. Please subscribe to our blog posts to learn more interesting features in PostgreSQL.


R3dr0ck!




pmm-admin add postgresql --username=pmm --password=Open@123 PPI-PROD-PG02 173.11.9.83:5665


pmm-admin remove :
-------------------

pmm-admin remove postgresql(Service type) postgres(Service name)


service type : mysql,mongodb,postgresql,proxysql,haproxy,external



ALTER USER pmmusr WITH PASSWORD 'Open@123';


pmm-admin add postgresql --username=pmm_db --password=Open@123 indus-DR 172.29.7.6:5665



psql -c "CREATE USER pmm WITH ENCRYPTED PASSWORD 'Open@123'"
echo "host    all             pmm        172.184.9.46/32        md5" >> $PGDATA/pg_hba.conf
sudo yum install pmm2-client -y
sudo pmm-admin config --server-insecure-tls --force --server-url=https://dbamon:Pmmdb@123@172.150.0.56:443
pmm-admin add postgresql --username=pmm --password=Open@123 PPI-PROD-PG01 172.184.9.46:5665
psql -h 172.184.9.46 -p 5665 -U pmm -d postgres
psql -h 172.184.1.48 -p 5665 -U pmm -d postgres
pmm-admin add postgresql --username=pmm --password=Open@123 RECON-SHARED-PG01 172.184.1.48:5665
pmm-admin list
history | grep pmm




sudo percona-release setup ppg14

 ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_monitor';

