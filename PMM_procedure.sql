PMM Server , Client Setup [ Complete Document ]

In this Example , I have taken 2 MariaDB servers and 1 PMM Server. 
Deployed 3 RHEL 8 Versions for PMM setup ... [ EC2 ]

MariaDB server 1  vasu-maria1-pmm-poc  172.31.22.44 [Private IP Address] 
MariaDB server 2  vasu-maria2-pmm-poc  172.31.16.154[Private IP Address ]
PMM server        vasu-pmm-poc         172.31.17.0 [ Private IP Address ]

Security Group = Default 
VPC 		    = Default 

Reference Link =  #

#############################################################################
Step - 1 :- Install MariaDB on Both servers
#############################################################################

DB Version = 10.3.12

[root@ip-172-31-22-44 ~]# groupadd mysql
[root@ip-172-31-22-44 ~]# useradd mysql -g mysql
[root@ip-172-31-22-44 ~]# mkdir /home/maria/
[root@ip-172-31-22-44 ~]# mkdir /home/maria/data
[root@ip-172-31-22-44 ~]# mkdir /home/maria/log
[root@ip-172-31-22-44 ~]# chown -R mysql:mysql /home/maria/data
[root@ip-172-31-22-44 ~]# chown -R mysql:mysql /home/maria/log
[root@ip-172-31-22-44 ~]# cd /usr/local/
[root@ip-172-31-22-44 local]# wget https://archive.mariadb.org//mariadb-10.3.12/bintar-linux-x86_64/mariadb-10.3.12-linux-x86_64.tar.gz
[root@ip-172-31-22-44 local]# tar zxvf mariadb-10.3.12-linux-x86_64.tar.gz
[root@ip-172-31-22-44 local]# ln -s mariadb-10.3.12-linux-x86_64 mysql
[root@ip-172-31-22-44 local]# cd mysql/
[root@ip-172-31-22-44 mysql]# pwd
/usr/local/mysql
[root@ip-172-31-22-44 mysql]# yum install libaio
[root@ip-172-31-22-44 mysql]# ./scripts/mysql_install_db --user=mysql --datadir=/home/maria/data
[root@ip-172-31-22-44 ~]# vi .bashrc
[root@ip-172-31-22-44 ~]# source .bashrc
[root@ip-172-31-22-44 ~]# cat .bashrc
# .bashrc
# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
PATH=$PATH:/usr/local/mysql/bin/

[root@ip-172-31-22-44 etc]# vi my.cnf
[root@ip-172-31-22-44 etc]# cat my.cnf
[client]
port = 3306
socket = /home/maria/data/mysql.sock

[mysqld]
server_id = 1
datadir=/home/maria/data
socket=/home/maria/data/mysql.sock
user=mysql
bind-address = 0.0.0.0
innodb_file_per_table=1
default_storage_engine=innodb
# enforce_innodb_engine=Innodb ##remove this parameter to avoid the error "ERROR 1286 (42000): Unknown storage engine 'partition'" when creating index
max_connections = 200
innodb_log_file_size=512M
innodb_buffer_pool_size = 256M
sync_binlog = 1
query_cache_type = 0
query_cache_size = 0
lower_case_table_names = 1
character_set_server = utf8mb4
collation_server = utf8mb4_unicode_520_ci
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
[mysqld_safe]
log-error=/home/maria/data/mysqld.log
pid-file=/home/maria/data/mysqld.pid
[root@ip-172-31-22-44 ~]# cd /usr/local/mysql/
[root@ip-172-31-22-44 mysql]# pwd
/usr/local/mysql
[root@ip-172-31-22-44 mysql]# sudo cp support-files/mysql.server /etc/init.d/mysql
[root@ip-172-31-22-44 mysql]# sudo chmod +x /etc/init.d/mysql
[root@ip-172-31-22-44 mysql]# sudo chkconfig --add mysql
[root@ip-172-31-22-44 mysql]# sudo chkconfig --list
[root@ip-172-31-22-44 mysql]# sudo chkconfig --level 345 mysql on
[root@ip-172-31-22-44 mysql]# sudo chkconfig --level 2 mysql off
[root@ip-172-31-22-44 mysql]# service mysql start
Starting mysql (via systemctl):                            [  OK  ]
[root@ip-172-31-22-44 ~]# yum install libtinfo*
[root@ip-172-31-22-44 ~]# mysql_secure_installation -S /home/maria/data/mysql.sock

NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user.  If you've just installed MariaDB, and
you haven't set the root password yet, the password will be blank,
so you should just press enter here.

Enter current password for root (enter for none):
OK, successfully used password, moving on...

Setting the root password ensures that nobody can log into the MariaDB
root user without the proper authorisation.

Set root password? [Y/n] y
New password:mariapassword
Re-enter new password:mariapassword
Password updated successfully!
Reloading privilege tables..
 ... Success!


By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] y
 ... Success!

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
[root@ip-172-31-22-44 ~]# mysql -u root -p
Enter password:mariapassword 
Welcome to the MariaDB monitor.  Commands end with ; or \g.Your MariaDB connection id is 17.Server version: 10.3.12-MariaDB MariaDB Server
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> select version();
+-----------------+
| version()       |
+-----------------+
| 10.3.12-MariaDB |
+-----------------+
1 row in set (0.000 sec)




#############################################################################
Step - 2 :- Replication setup between both MariaDB servers with GTID
#############################################################################

MariaDB server 1  vasu-maria1-pmm-poc  172.31.22.44 [Private IP Address] 
MariaDB server 2  vasu-maria2-pmm-poc  172.31.16.154[Private IP Address ]


(1) Add the entry on configuration files, and make sure the binlogs are enabled. [ In Main Server ]

(2) Restart the main server service 

MariaDB [(none)]> system hostname -I
172.31.22.44
MariaDB [(none)]> show variables like '%log_bin%';
+---------------------------------+---------------------------+
| Variable_name                   | Value                     |
+---------------------------------+---------------------------+
| log_bin                         | ON                        |
| log_bin_basename                | /home/maria/data/ON       |
| log_bin_compress                | OFF                       |
| log_bin_compress_min_len        | 256                       |
| log_bin_index                   | /home/maria/data/ON.index |
| log_bin_trust_function_creators | OFF                       |
| sql_log_bin                     | ON                        |
+---------------------------------+---------------------------+
7 rows in set (0.001 sec)

MariaDB [(none)]> show binary logs;
+-----------+-----------+
| Log_name  | File_size |
+-----------+-----------+
| ON.000001 |       321 |
+-----------+-----------+
1 row in set (0.000 sec)

MariaDB [(none)]> SHOW MASTER STATUS;
+-----------+----------+--------------+------------------+
| File      | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+-----------+----------+--------------+------------------+
| ON.000001 |      321 |              |                  |
+-----------+----------+--------------+------------------+
1 row in set (0.000 sec)

(3) Create replication user in main Server ..

MariaDB [(none)]> select user,host,password from mysql.user;
+------+-----------+-------------------------------------------+
| user | host      | password                                  |
+------+-----------+-------------------------------------------+
| root | localhost | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root | 127.0.0.1 | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root | ::1       | *84A39D41433A3044C57427018E7C05C80B363C48 |
+------+-----------+-------------------------------------------+
3 rows in set (0.000 sec)

MariaDB [(none)]> CREATE USER 'replication'@'%' IDENTIFIED BY 'replication';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* to 'replication'@'%';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> select user,host,password from mysql.user;
+-------------+-----------+-------------------------------------------+
| user        | host      | password                                  |
+-------------+-----------+-------------------------------------------+
| root        | localhost | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root        | 127.0.0.1 | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root        | ::1       | *84A39D41433A3044C57427018E7C05C80B363C48 |
| replication | %         | *D36660B5249B066D7AC5A1A14CECB71D36944CBC |
+-------------+-----------+-------------------------------------------+
4 rows in set (0.000 sec)

(4) On replica Server :- 
Add slave parameter in my.cnf. Make sure the server_id is different from master server. Since this is slave for read only access, making the read_only: ON

MariaDB [(none)]> system hostname -I
172.31.16.154
MariaDB [(none)]> show variables like '%read_only%';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| innodb_read_only | OFF   |
| read_only        | ON    |
| tx_read_only     | OFF   |
+------------------+-------+
3 rows in set (0.001 sec)

MariaDB [(none)]> show variables like '%server%';
+---------------------------------+------------------------+
| Variable_name                   | Value                  |
+---------------------------------+------------------------+
| character_set_server            | utf8mb4                |
| collation_server                | utf8mb4_unicode_520_ci |
| innodb_ft_server_stopword_table |                        |
| server_id                       | 2                      |
+---------------------------------+------------------------+
4 rows in set (0.001 sec)

(5) Run the CHANGE MASTER and start the slave :-

MariaDB [(none)]> system hostname -I
172.31.16.154
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='172.31.22.44', MASTER_USER='replication', MASTER_PASSWORD='replication', MASTER_LOG_FILE='ON.000001', MASTER_LOG_POS=776;
Query OK, 0 rows affected (0.010 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 172.31.22.44
                   Master_User: replication
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: ON.000001
           Read_Master_Log_Pos: 776
                Relay_Log_File: ip-172-31-16-154-relay-bin.000002
                 Relay_Log_Pos: 548
         Relay_Master_Log_File: ON.000001
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
               Replicate_Do_DB:
           Replicate_Ignore_DB:
            Replicate_Do_Table:
        Replicate_Ignore_Table:
       Replicate_Wild_Do_Table:
   Replicate_Wild_Ignore_Table:
                    Last_Errno: 0
                    Last_Error:
                  Skip_Counter: 0
           Exec_Master_Log_Pos: 776
               Relay_Log_Space: 868
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: 0
 Master_SSL_Verify_Server_Cert: No
                 Last_IO_Errno: 0
                 Last_IO_Error:
                Last_SQL_Errno: 0
                Last_SQL_Error:
   Replicate_Ignore_Server_Ids:
              Master_Server_Id: 1
                Master_SSL_Crl:
            Master_SSL_Crlpath:
                    Using_Gtid: No
                   Gtid_IO_Pos:
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: conservative
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
              Slave_DDL_Groups: 0
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
1 row in set (0.000 sec)

(6) Verification for Replication  :-

In Main server :-

MariaDB [(none)]> system hostname -I
172.31.22.44
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.001 sec)

MariaDB [(none)]> CREATE DATABASE replication;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| replication        |
+--------------------+
4 rows in set (0.000 sec)

In replica server :-

MariaDB [(none)]> system hostname -I
172.31.16.154
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| replication        |
+--------------------+
4 rows in set (0.001 sec)

(7) Replication by GTID :- 

Add the below parameters in main server for the my.cnf and then restart the server.

server_id=1
log_slave_updates=1
sync_binlog=1
innodb_flush_log_at_trx_commit=1
gtid-domain-id=22

(8) Get the co-ordinates on mysql master server.

In Main Server  :-

MariaDB [(none)]> system hostname -I
172.31.22.44
MariaDB [(none)]> SHOW MASTER STATUS;
+-----------+----------+--------------+------------------+
| File      | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+-----------+----------+--------------+------------------+
| ON.000003 |      335 |              |                  |
+-----------+----------+--------------+------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> SELECT BINLOG_GTID_POS('ON.000003',335);
+----------------------------------+
| BINLOG_GTID_POS('ON.000003',335) |
+----------------------------------+
| 0-1-4                            |
+----------------------------------+
1 row in set (0.000 sec)

In replica Server :-

MariaDB [(none)]> system hostname -I
172.31.16.154
MariaDB [(none)]> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 172.31.22.44
                   Master_User: replication
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: ON.000003
           Read_Master_Log_Pos: 335
                Relay_Log_File: ip-172-31-16-154-relay-bin.000005
                 Relay_Log_Pos: 627
         Relay_Master_Log_File: ON.000003
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
               Replicate_Do_DB:
           Replicate_Ignore_DB:
            Replicate_Do_Table:
        Replicate_Ignore_Table:
       Replicate_Wild_Do_Table:
   Replicate_Wild_Ignore_Table:
                    Last_Errno: 0
                    Last_Error:
                  Skip_Counter: 0
           Exec_Master_Log_Pos: 335
               Relay_Log_Space: 1318
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: 0
 Master_SSL_Verify_Server_Cert: No
                 Last_IO_Errno: 0
                 Last_IO_Error:
                Last_SQL_Errno: 0
                Last_SQL_Error:
   Replicate_Ignore_Server_Ids:
              Master_Server_Id: 1
                Master_SSL_Crl:
            Master_SSL_Crlpath:
                    Using_Gtid: No
                   Gtid_IO_Pos:
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: conservative
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
              Slave_DDL_Groups: 1
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
1 row in set (0.000 sec)

MariaDB [(none)]> STOP SLAVE;
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> SET GLOBAL gtid_slave_pos = '0-1-4';
Query OK, 0 rows affected (0.015 sec)

MariaDB [(none)]> CHANGE MASTER TO master_use_gtid=slave_pos;
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.008 sec)

MariaDB [(none)]> SHOW SLAVE STATUS\G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 172.31.22.44
                   Master_User: replication
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: ON.000003
           Read_Master_Log_Pos: 335
                Relay_Log_File: ip-172-31-16-154-relay-bin.000002
                 Relay_Log_Pos: 627
         Relay_Master_Log_File: ON.000003
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
               Replicate_Do_DB:
           Replicate_Ignore_DB:
            Replicate_Do_Table:
        Replicate_Ignore_Table:
       Replicate_Wild_Do_Table:
   Replicate_Wild_Ignore_Table:
                    Last_Errno: 0
                    Last_Error:
                  Skip_Counter: 0
           Exec_Master_Log_Pos: 335
               Relay_Log_Space: 947
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: 0
 Master_SSL_Verify_Server_Cert: No
                 Last_IO_Errno: 0
                 Last_IO_Error:
                Last_SQL_Errno: 0
                Last_SQL_Error:
   Replicate_Ignore_Server_Ids:
              Master_Server_Id: 1
                Master_SSL_Crl:
            Master_SSL_Crlpath:
                    Using_Gtid: Slave_Pos
                   Gtid_IO_Pos: 0-1-4
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: conservative
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
              Slave_DDL_Groups: 1
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
1 row in set (0.000 sec)

(9)  Verification GTID setup for main and Replica servers

In Main server :

MariaDB [(none)]> system hostname -I
172.31.22.44
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| replication        |
+--------------------+
4 rows in set (0.000 sec)

MariaDB [(none)]> create database replication_gtid;
Query OK, 1 row affected (0.002 sec)

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| replication        |
| replication_gtid   |
+--------------------+
5 rows in set (0.000 sec)

In replica Server :-

MariaDB [(none)]> system hostname -I
172.31.16.154
MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| replication        |
| replication_gtid   |
+--------------------+
5 rows in set (0.000 sec)

GTID is working ...........



#############################################
Step - 3 :- PMM Server Setup in pmm Server
#############################################

MariaDB server 1  vasu-maria1-pmm-poc  172.31.22.44 [Private IP Address] 
MariaDB server 2  vasu-maria2-pmm-poc  172.31.16.154[Private IP Address ]
PMM server        vasu-pmm-poc         172.31.17.0 [ Private IP Address ]
                                           34.230.88.10 [ Public Ip address ]

I have created Elastic IP Address for all 3 Servers..

Main Server 
Replica Server
PMM Server 

Now public IP Address for above servers .

vasu-maria1-pmm-poc ==> 44.196.150.226
vasu-maria2-pmm-poc ==> 34.228.90.130 
vasu-pmm-poc ==> 44.196.179.230


Install Percona Monitoring and Management
--------------------------------------------

Step 1: Install Server
-----------------------------


Applies to: All Docker compatible *nix based systems

(1) Requirements: Docker

[root@ip-172-31-17-0 ~]# yum install docker

[root@ip-172-31-17-0 ~]# rpm -qa | grep -i docker
docker-20.10.4-1.amzn2.x86_64

[root@ip-172-31-17-0 ~]# service docker status
Redirecting to /bin/systemctl status docker.service
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
     Docs: https://docs.docker.com

[root@ip-172-31-17-0 ~]# service docker start
Redirecting to /bin/systemctl start docker.service

[root@ip-172-31-17-0 ~]# service docker status
Redirecting to /bin/systemctl status docker.service
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2021-07-29 13:40:58 UTC; 1s ago
     Docs: https://docs.docker.com
  Process: 3647 ExecStartPre=/usr/libexec/docker/docker-setup-runtimes.sh (code=exited, status=0/SUCCESS)
  Process: 3636 ExecStartPre=/bin/mkdir -p /run/docker (code=exited, status=0/SUCCESS)
 Main PID: 3658 (dockerd)
    Tasks: 9
   Memory: 38.8M
   CGroup: /system.slice/docker.service
           └─3658 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --default-ulimit nofile=1024:4096

Jul 29 13:40:57 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:57.617345293Z" level=info msg="scheme \"unix\" not regi...e=grpc
Jul 29 13:40:57 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:57.617364421Z" level=info msg="ccResolverWrapper: sendi...e=grpc
Jul 29 13:40:57 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:57.617387861Z" level=info msg="ClientConn switching bal...e=grpc
Jul 29 13:40:57 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:57.666097590Z" level=info msg="Loading containers: start."
Jul 29 13:40:57 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:57.928408050Z" level=info msg="Default bridge (docker0)...dress"
Jul 29 13:40:58 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:58.118184672Z" level=info msg="Loading containers: done."
Jul 29 13:40:58 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:58.145315685Z" level=info msg="Docker daemon" commit=36...0.10.4
Jul 29 13:40:58 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:58.145422948Z" level=info msg="Daemon has completed ini...ation"
Jul 29 13:40:58 ip-172-31-17-0.ec2.internal systemd[1]: Started Docker Application Container Engine.
Jul 29 13:40:58 ip-172-31-17-0.ec2.internal dockerd[3658]: time="2021-07-29T13:40:58.173852614Z" level=info msg="API listen on /run/docker.sock"
Hint: Some lines were ellipsized, use -l to show in full.

(2) Create data volume:

[root@ip-172-31-17-0 ~]# sudo  docker create -v /srv --name pmm-data percona/pmm-server:2 /bin/true
Unable to find image 'percona/pmm-server:2' locally
2: Pulling from percona/pmm-server
2d473b07cdd5: Pull complete
178efec65a21: Pull complete
Digest: sha256:65c654312070ac08cecb8d2be203d04ad018cfb646b7a8ff800f8927a05c9944
Status: Downloaded newer image for percona/pmm-server:2
1f3c4b2703d187da2318ca3fdfaad16c0360b7e0ca5f9ab00542cf54544946b7

[root@ip-172-31-17-0 ~]# docker ps -a
CONTAINER ID   IMAGE                  COMMAND       CREATED          STATUS    PORTS     NAMES
1f3c4b2703d1   percona/pmm-server:2   "/bin/true"   50 seconds ago   Created             pmm-data


(3) Create pmm-server docker container:

[root@ip-172-31-17-0 ~]# sudo docker run -d -p 80:80 -p 443:443 --volumes-from pmm-data --name pmm-server --restart always percona/pmm-server:2
440e11f9237e7d92d356b7da7c4e702560f99f9870106d3a205d5ea07823301b

[root@ip-172-31-17-0 ~]# docker ps -a
CONTAINER ID   IMAGE                  COMMAND                CREATED       STATUS                 PORTS                                      NAMES
440e11f9237e   percona/pmm-server:2   "/opt/entrypoint.sh"   2 hours ago   Up 2 hours (healthy)   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   pmm-server
1f3c4b2703d1   percona/pmm-server:2   "/bin/true"            2 hours ago   Created                                                           pmm-data

(4) Connect to Percona Monitoring and Management:

https://<IP Address or hostname of your Percona Monitoring and Management Server>:443

http://34.230.88.10:443 ===========> This is my public ipaddress of EC2 machine . If i give Private ipaddress , it was not connecting .. so i given public Ipaddress and able to login 

or 

http://34.230.88.10/

Default username/password is admin/admin and should be changed on first login



Step 2: Install Client
-------------------------------

pmm-client we have to install in 2 MariaDB servers [ If we have replication , we should install pmm-client in both servers ].


(1) Download and install Percona Repo Package

Connect to the Main [ Master ]  Server , install pmm-client.
--------------------------------------------------------------

[root@ip-172-31-22-44 ~]# hostname -I
172.31.22.44

[root@ip-172-31-22-44 ~]# pwd
/root

[root@ip-172-31-22-44 ~]# ls -ltr
-rw-------. 1 root root 6699 May  4 17:33 original-ks.cfg
-rw-------. 1 root root 6953 May  4 17:33 anaconda-ks.cfg

[root@ip-172-31-22-44 ~]# hostname -I
172.31.22.44

[root@ip-172-31-22-44 ~]# sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.

Last metadata expiration check: 3:27:46 ago on Thu 29 Jul 2021 12:07:31 PM UTC.
percona-release-latest.noarch.rpm                                                                                             324 kB/s |  19 kB     00:00
Dependencies resolved.
===========================================================================
 Package                                    Architecture                      Version                           Repository                               Size
===========================================================================
Installing:
 percona-release                            noarch                            1.0-26                            @commandline                             19 k

Transaction Summary
===========================================================================
Install  1 Package

Total size: 19 k
Installed size: 31 k
Is this ok [y/N]: y
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                      1/1
  Installing       : percona-release-1.0-26.noarch                                                                                                        1/1
  Running scriptlet: percona-release-1.0-26.noarch                                                                                                        1/1
* Enabling the Percona Original repository
<*> All done!
* Enabling the Percona Release repository
<*> All done!
The percona-release package now contains a percona-release script that can enable additional repositories for our newer products.

For example, to enable the Percona Server 8.0 repository use:

  percona-release setup ps80

Note: To avoid conflicts with older product versions, the percona-release setup command may disable our original repository for some products.

For more information, please visit:
  https://www.percona.com/doc/percona-repo-config/percona-release.html


  Verifying        : percona-release-1.0-26.noarch                                                                                                        1/1
Installed products updated.

Installed:
  percona-release-1.0-26.noarch

Complete!

Connect to the replica [ slave ]  Server , install pmm-client.
----------------------------------------------------------------

[root@ip-172-31-16-154 ~]# pwd
/root

[root@ip-172-31-16-154 ~]# hostname -I
172.31.16.154

[root@ip-172-31-16-154 ~]# sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.

Last metadata expiration check: 4:31:00 ago on Thu 29 Jul 2021 12:34:38 PM UTC.
percona-release-latest.noarch.rpm                                                                                   57 kB/s |  19 kB     00:00
Dependencies resolved.
===========================================================================
 Package                                 Architecture                   Version                         Repository                            Size
===========================================================================
Installing:
 percona-release                         noarch                         1.0-26                          @commandline                          19 k

Transaction Summary
===========================================================================
Install  1 Package

Total size: 19 k
Installed size: 31 k
Is this ok [y/N]: y
Downloading Packages:
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                           1/1
  Installing       : percona-release-1.0-26.noarch                                                                                             1/1
  Running scriptlet: percona-release-1.0-26.noarch                                                                                             1/1
* Enabling the Percona Original repository
<*> All done!
* Enabling the Percona Release repository
<*> All done!
The percona-release package now contains a percona-release script that can enable additional repositories for our newer products.

For example, to enable the Percona Server 8.0 repository use:

  percona-release setup ps80

Note: To avoid conflicts with older product versions, the percona-release setup command may disable our original repository for some products.

For more information, please visit:
  https://www.percona.com/doc/percona-repo-config/percona-release.html


  Verifying        : percona-release-1.0-26.noarch                                                                                             1/1
Installed products updated.

Installed:
  percona-release-1.0-26.noarch

Complete!


(2) Install Percona Monitoring and Management Client

In Main DB server [ Master ] :-
----------------------------------
[root@ip-172-31-22-44 ~]# hostname -I
172.31.22.44

[root@ip-172-31-22-44 ~]# sudo yum install pmm2-client
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.

Percona Original release/x86_64 YUM repository                                                                    2.7 MB/s | 6.9 MB     00:02
Percona Original release/noarch YUM repository                                                                    109 kB/s | 3.4 kB     00:00
Percona Release release/noarch YUM repository                                                                      48 kB/s | 1.6 kB     00:00
Dependencies resolved.
===========================================================================
 Package                          Architecture                Version                           Repository                                   Size
===========================================================================
Installing:
 pmm2-client                      x86_64                      2.19.0-6.el8                      percona-release-x86_64                       43 M

Transaction Summary
===========================================================================
Install  1 Package

Total download size: 43 M
Installed size: 43 M
Is this ok [y/N]: y
Downloading Packages:
pmm2-client-2.19.0-6.el8.x86_64.rpm                                                                                18 MB/s |  43 MB     00:02
---------------------------------------------------------------------------
Total                                                                                                              18 MB/s |  43 MB     00:02
warning: /var/cache/dnf/percona-release-x86_64-018d36333a0b53bc/packages/pmm2-client-2.19.0-6.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 8507efa5: NOKEY
Percona Original release/x86_64 YUM repository                                                                    4.5 MB/s | 4.7 kB     00:00
Importing GPG key 0x8507EFA5:
 Userid     : "Percona Development Team (Packaging key) <info@percona.com>"
 Fingerprint: 4D1B B29D 63D9 8E42 2B21 13B1 9334 A25F 8507 EFA5
 From       : /etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY
Is this ok [y/N]: y
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                          1/1
  Running scriptlet: pmm2-client-2.19.0-6.el8.x86_64                                                                                          1/1
  Installing       : pmm2-client-2.19.0-6.el8.x86_64                                                                                          1/1
  Running scriptlet: pmm2-client-2.19.0-6.el8.x86_64                                                                                          1/1
  Verifying        : pmm2-client-2.19.0-6.el8.x86_64                                                                                          1/1
Installed products updated.

Installed:
  pmm2-client-2.19.0-6.el8.x86_64

Complete!

In Replica DB server [ Slave  ] :-
----------------------------------

[root@ip-172-31-16-154 ~]# hostname -I
172.31.16.154

[root@ip-172-31-16-154 ~]# sudo yum install pmm2-client
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.

Percona Original release/x86_64 YUM repository                                                                     2.3 MB/s | 6.9 MB     00:03
Percona Original release/noarch YUM repository                                                                      21 kB/s | 3.4 kB     00:00
Percona Release release/noarch YUM repository                                                                       47 kB/s | 1.6 kB     00:00
Dependencies resolved.
===========================================================================
 Package                          Architecture                Version                            Repository                                   Size
===========================================================================
Installing:
 

pmm2-client                      x86_64                      2.19.0-6.el8                       percona-release-x86_64                       43 M

Transaction Summary
===========================================================================
Install  1 Package

Total download size: 43 M
Installed size: 43 M
Is this ok [y/N]: y
Downloading Packages:
pmm2-client-2.19.0-6.el8.x86_64.rpm                                                                                 20 MB/s |  43 MB     00:02
---------------------------------------------------------------------------
Total                                                                                                               20 MB/s |  43 MB     00:02
warning: /var/cache/dnf/percona-release-x86_64-018d36333a0b53bc/packages/pmm2-client-2.19.0-6.el8.x86_64.rpm: Header V4 RSA/SHA256 Signature, key ID 8507efa5: NOKEY
Percona Original release/x86_64 YUM repository                                                                     4.5 MB/s | 4.7 kB     00:00
Importing GPG key 0x8507EFA5:
 Userid     : "Percona Development Team (Packaging key) <info@percona.com>"
 Fingerprint: 4D1B B29D 63D9 8E42 2B21 13B1 9334 A25F 8507 EFA5
 From       : /etc/pki/rpm-gpg/PERCONA-PACKAGING-KEY
Is this ok [y/N]: y
Key imported successfully
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                           1/1
  Running scriptlet: pmm2-client-2.19.0-6.el8.x86_64                                                                                           1/1
  Installing       : pmm2-client-2.19.0-6.el8.x86_64                                                                                           1/1
  Running scriptlet: pmm2-client-2.19.0-6.el8.x86_64                                                                                           1/1
  Verifying        : pmm2-client-2.19.0-6.el8.x86_64                                                                                           1/1
Installed products updated.

Installed:
  pmm2-client-2.19.0-6.el8.x86_64

Complete!



Step 3: Connect Client to Server
---------------------------------------

Applies to: All (optional if only using AWS Monitoring)

Requirements: Client to server communication to secure port on pmm-server (443 assumed) — must be performed on every system to be monitored.

Register Percona Monitoring and Management client with server

In Main Server [ Master ] :- [ Here 44.196.179.230 is PMM Public IpAddress. ] 
-----------------------------

[root@ip-172-31-22-44 ~]# hostname -I
172.31.22.44

[root@ip-172-31-22-44 ~]# sudo pmm-admin config --server-insecure-tls --server-url=https://admin:admin@44.196.179.230
Checking local pmm-agent status...
pmm-agent is running.
Registering pmm-agent on PMM Server...
Registered.
Configuration file /usr/local/percona/pmm2/config/pmm-agent.yaml updated.
Reloading pmm-agent configuration...
Configuration reloaded.
Checking local pmm-agent status...
pmm-agent is running.
[root@ip-172-31-22-44 ~]#

In Replica Server [ Slave ] :-
----------------------------------

[root@ip-172-31-16-154 ~]# hostname -I
172.31.16.154

[root@ip-172-31-16-154 ~]# sudo pmm-admin config --server-insecure-tls --server-url=https://admin:admin@44.196.179.230
Checking local pmm-agent status...
pmm-agent is running.
Registering pmm-agent on PMM Server...
Registered.
Configuration file /usr/local/percona/pmm2/config/pmm-agent.yaml updated.
Reloading pmm-agent configuration...
Configuration reloaded.
Checking local pmm-agent status...
pmm-agent is running.
[root@ip-172-31-16-154 ~]#


Step 4: Monitor Database
-----------------------------------

Applies to: All
Requirements: Server to client communication over ports, 42000 - 51999 by default.


(1) Create a Percona Monitoring and Management specific user for monitoring (using mysql CLI)

In Main Server [ Master ] :-
----------------------------------

[root@ip-172-31-22-44 ~]# hostname -I
172.31.22.44

[root@ip-172-31-22-44 ~]# mysql -u root -p
Enter password:mariapassword 
Welcome to the MariaDB monitor.  Commands end with ; or \g.Your MariaDB connection id is 15.Server version: 10.3.12-MariaDB-log MariaDB Server
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> select user,host,password from mysql.user;
+-------------+-----------+-------------------------------------------+
| user        | host      | password                                  |
+-------------+-----------+-------------------------------------------+
| root        | localhost | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root        | 127.0.0.1 | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root        | ::1       | *84A39D41433A3044C57427018E7C05C80B363C48 |
| replication | %         | *D36660B5249B066D7AC5A1A14CECB71D36944CBC |
+-------------+-----------+-------------------------------------------+
4 rows in set (0.000 sec)

MariaDB [(none)]> CREATE USER 'pmm'@'%' IDENTIFIED BY 'pmm' WITH MAX_USER_CONNECTIONS 10;
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> GRANT SELECT, PROCESS, SUPER, REPLICATION CLIENT, RELOAD ON *.* TO 'pmm'@'%';
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.004 sec)

In Replica Server [ Slave ]:-
------------------------------------

[root@ip-172-31-16-154 ~]# hostname -I
172.31.16.154

[root@ip-172-31-16-154 ~]# mysql -u root -pmariapassword
Welcome to the MariaDB monitor.  Commands end with ; or \g.Your MariaDB connection id is 17.Server version: 10.3.12-MariaDB MariaDB Server
Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> select user,host,password from mysql.user;
+------+-----------+-------------------------------------------+
| user | host      | password                                  |
+------+-----------+-------------------------------------------+
| root | localhost | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root | 127.0.0.1 | *84A39D41433A3044C57427018E7C05C80B363C48 |
| root | ::1       | *84A39D41433A3044C57427018E7C05C80B363C48 |
| pmm  | %         | *E5AE1591B8643BFA224135CDDFD6EB8B303DC33E |
+------+-----------+-------------------------------------------+
4 rows in set (0.000 sec)

(2) Database Configuration:-
-----------------------------
For the MariaDB/MySQL database being monitored, enable following settings as best practice:

innodb_monitor_enable=all
performance_schema=ON

In Main Server [ Master ] :-
------------------------

MariaDB [(none)]> system hostname -I
172.31.22.44

MariaDB [(none)]> show variables like '%performance%';
+--------------------------------------------------------+-------+
| Variable_name                                          | Value |
+--------------------------------------------------------+-------+
| performance_schema                                     | OFF   |
| performance_schema_accounts_size                       | -1    |
| performance_schema_digests_size                        | -1    |
| performance_schema_events_stages_history_long_size     | -1    |
| performance_schema_events_stages_history_size          | -1    |
| performance_schema_events_statements_history_long_size | -1    |
| performance_schema_events_statements_history_size      | -1    |
| performance_schema_events_waits_history_long_size      | -1    |
| performance_schema_events_waits_history_size           | -1    |
| performance_schema_hosts_size                          | -1    |
| performance_schema_max_cond_classes                    | 80    |
| performance_schema_max_cond_instances                  | -1    |
| performance_schema_max_digest_length                   | 1024  |
| performance_schema_max_file_classes                    | 50    |
| performance_schema_max_file_handles                    | 32768 |
| performance_schema_max_file_instances                  | -1    |
| performance_schema_max_mutex_classes                   | 200   |
| performance_schema_max_mutex_instances                 | -1    |
| performance_schema_max_rwlock_classes                  | 40    |
| performance_schema_max_rwlock_instances                | -1    |
| performance_schema_max_socket_classes                  | 10    |
| performance_schema_max_socket_instances                | -1    |
| performance_schema_max_stage_classes                   | 160   |
| performance_schema_max_statement_classes               | 200   |
| performance_schema_max_table_handles                   | -1    |
| performance_schema_max_table_instances                 | -1    |
| performance_schema_max_thread_classes                  | 50    |
| performance_schema_max_thread_instances                | -1    |
| performance_schema_session_connect_attrs_size          | -1    |
| performance_schema_setup_actors_size                   | 100   |
| performance_schema_setup_objects_size                  | 100   |
| performance_schema_users_size                          | -1    |
+--------------------------------------------------------+-------+
32 rows in set (0.001 sec)

MariaDB [(none)]> show variables like 'innodb_monitor%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_monitor_disable   |       |
| innodb_monitor_enable    |       |
| innodb_monitor_reset     |       |
| innodb_monitor_reset_all |       |
+--------------------------+-------+
4 rows in set (0.001 sec)

In Replica Server [ slave ]
------------------------------------

MariaDB [(none)]> system hostname -I
172.31.16.154
MariaDB [(none)]> show variables like '%performance%';
+--------------------------------------------------------+-------+
| Variable_name                                          | Value |
+--------------------------------------------------------+-------+
| performance_schema                                     | OFF   |
| performance_schema_accounts_size                       | -1    |
| performance_schema_digests_size                        | -1    |
| performance_schema_events_stages_history_long_size     | -1    |
| performance_schema_events_stages_history_size          | -1    |
| performance_schema_events_statements_history_long_size | -1    |
| performance_schema_events_statements_history_size      | -1    |
| performance_schema_events_waits_history_long_size      | -1    |
| performance_schema_events_waits_history_size           | -1    |
| performance_schema_hosts_size                          | -1    |
| performance_schema_max_cond_classes                    | 80    |
| performance_schema_max_cond_instances                  | -1    |
| performance_schema_max_digest_length                   | 1024  |
| performance_schema_max_file_classes                    | 50    |
| performance_schema_max_file_handles                    | 32768 |
| performance_schema_max_file_instances                  | -1    |
| performance_schema_max_mutex_classes                   | 200   |
| performance_schema_max_mutex_instances                 | -1    |
| performance_schema_max_rwlock_classes                  | 40    |
| performance_schema_max_rwlock_instances                | -1    |
| performance_schema_max_socket_classes                  | 10    |
| performance_schema_max_socket_instances                | -1    |
| performance_schema_max_stage_classes                   | 160   |
| performance_schema_max_statement_classes               | 200   |
| performance_schema_max_table_handles                   | -1    |
| performance_schema_max_table_instances                 | -1    |
| performance_schema_max_thread_classes                  | 50    |
| performance_schema_max_thread_instances                | -1    |
| performance_schema_session_connect_attrs_size          | -1    |
| performance_schema_setup_actors_size                   | 100   |
| performance_schema_setup_objects_size                  | 100   |
| performance_schema_users_size                          | -1    |
+--------------------------------------------------------+-------+
32 rows in set (0.001 sec)

MariaDB [(none)]> show variables like 'innodb_monitor%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_monitor_disable   |       |
| innodb_monitor_enable    |       |
| innodb_monitor_reset     |       |
| innodb_monitor_reset_all |       |
+--------------------------+-------+
4 rows in set (0.001 sec)

Note :- Should enable the below parameters in Main Server and Replica Server in my.cnf and restart the MariaDB database services:-

innodb_monitor_enable = all
performance_schema = ON

[root@ip-172-31-22-44 ~]# service mysql restart
Starting mysql (via systemctl):                            [  OK  ]
[root@ip-172-31-22-44 ~]#

[root@ip-172-31-16-154 ~]# service mysql restart
Starting mysql (via systemctl):                            [  OK  ]
[root@ip-172-31-16-154 ~]#




In Main Server [ Master ]
--------------------------------------

MariaDB [(none)]> system hostname -I
172.31.22.44

MariaDB [(none)]> show variables like '%performance%';
+--------------------------------------------------------+-------+
| Variable_name                                          | Value |
+--------------------------------------------------------+-------+
| performance_schema                                     | ON    |
| performance_schema_accounts_size                       | 100   |
| performance_schema_digests_size                        | 5000  |
| performance_schema_events_stages_history_long_size     | 1000  |
| performance_schema_events_stages_history_size          | 20    |
| performance_schema_events_statements_history_long_size | 1000  |
| performance_schema_events_statements_history_size      | 20    |
| performance_schema_events_waits_history_long_size      | 1000  |
| performance_schema_events_waits_history_size           | 20    |
| performance_schema_hosts_size                          | 100   |
| performance_schema_max_cond_classes                    | 80    |
| performance_schema_max_cond_instances                  | 1500  |
| performance_schema_max_digest_length                   | 1024  |
| performance_schema_max_file_classes                    | 50    |
| performance_schema_max_file_handles                    | 32768 |
| performance_schema_max_file_instances                  | 2500  |
| performance_schema_max_mutex_classes                   | 200   |
| performance_schema_max_mutex_instances                 | 5858  |
| performance_schema_max_rwlock_classes                  | 40    |
| performance_schema_max_rwlock_instances                | 3143  |
| performance_schema_max_socket_classes                  | 10    |
| performance_schema_max_socket_instances                | 300   |
| performance_schema_max_stage_classes                   | 160   |
| performance_schema_max_statement_classes               | 200   |
| performance_schema_max_table_handles                   | 2858  |
| performance_schema_max_table_instances                 | 667   |
| performance_schema_max_thread_classes                  | 50    |
| performance_schema_max_thread_instances                | 358   |
| performance_schema_session_connect_attrs_size          | 512   |
| performance_schema_setup_actors_size                   | 100   |
| performance_schema_setup_objects_size                  | 100   |
| performance_schema_users_size                          | 100   |
+--------------------------------------------------------+-------+
32 rows in set (0.001 sec)

MariaDB [(none)]> show variables like 'innodb_monitor%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_monitor_disable   |       |
| innodb_monitor_enable    | all   |
| innodb_monitor_reset     |       |
| innodb_monitor_reset_all |       |
+--------------------------+-------+
4 rows in set (0.001 sec)

In Replica Server [ Slave ]
---------------------------------

MariaDB [(none)]> system hostname -I
172.31.16.154

MariaDB [(none)]> show variables like '%performance%';
+--------------------------------------------------------+-------+
| Variable_name                                          | Value |
+--------------------------------------------------------+-------+
| performance_schema                                     | ON    |
| performance_schema_accounts_size                       | 100   |
| performance_schema_digests_size                        | 5000  |
| performance_schema_events_stages_history_long_size     | 1000  |
| performance_schema_events_stages_history_size          | 20    |
| performance_schema_events_statements_history_long_size | 1000  |
| performance_schema_events_statements_history_size      | 20    |
| performance_schema_events_waits_history_long_size      | 1000  |
| performance_schema_events_waits_history_size           | 20    |
| performance_schema_hosts_size                          | 100   |
| performance_schema_max_cond_classes                    | 80    |
| performance_schema_max_cond_instances                  | 1500  |
| performance_schema_max_digest_length                   | 1024  |
| performance_schema_max_file_classes                    | 50    |
| performance_schema_max_file_handles                    | 32768 |
| performance_schema_max_file_instances                  | 2500  |
| performance_schema_max_mutex_classes                   | 200   |
| performance_schema_max_mutex_instances                 | 5858  |
| performance_schema_max_rwlock_classes                  | 40    |
| performance_schema_max_rwlock_instances                | 3143  |
| performance_schema_max_socket_classes                  | 10    |
| performance_schema_max_socket_instances                | 300   |
| performance_schema_max_stage_classes                   | 160   |
| performance_schema_max_statement_classes               | 200   |
| performance_schema_max_table_handles                   | 2858  |
| performance_schema_max_table_instances                 | 667   |
| performance_schema_max_thread_classes                  | 50    |
| performance_schema_max_thread_instances                | 358   |
| performance_schema_session_connect_attrs_size          | 512   |
| performance_schema_setup_actors_size                   | 100   |
| performance_schema_setup_objects_size                  | 100   |
| performance_schema_users_size                          | 100   |
+--------------------------------------------------------+-------+
32 rows in set (0.001 sec)

MariaDB [(none)]> show variables like 'innodb_monitor%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_monitor_disable   |       |
| innodb_monitor_enable    | all   |
| innodb_monitor_reset     |       |
| innodb_monitor_reset_all |       |
+--------------------------+-------+
4 rows in set (0.001 sec)

(3) Register the server for monitoring

In Main Server :-
-------------------

[root@ip-172-31-22-44 ~]# pmm-admin list
Service type        Service name        Address and port        Service ID

Agent type           Status           Metrics Mode        Agent ID                                              Service ID
pmm_agent            Connected                            /agent_id/0f43c776-fd89-4f39-a419-b184cdc6a436
node_exporter        Running          push                /agent_id/7a7f6d08-4902-4c91-b107-a5ec629fec9e
vmagent              Running          push                /agent_id/f2834a31-dcb6-4b6f-a680-0db4cc9cb193


In Replica Server :-
----------------------

[root@ip-172-31-16-154 ~]# pmm-admin list
Service type        Service name        Address and port        Service ID

Agent type           Status           Metrics Mode        Agent ID                                              Service ID
pmm_agent            Connected                            /agent_id/31d09271-b426-465f-ab36-b4aaa4ff4a91
node_exporter        Running          push                /agent_id/3a894355-f5d0-472d-9cd9-e0be2242c3c0
vmagent              Running          push                /agent_id/0b3a5dda-0c5c-445e-85b2-79a127d9c296


Adding MySQL Metrics and Query Analytics

In Main Server :- [ Master ]
--------------------------------

[root@ip-172-31-22-44 ~]# pmm-admin list
Service type        Service name        Address and port        Service ID

Agent type           Status           Metrics Mode        Agent ID                                              Service ID
pmm_agent            Connected                            /agent_id/15a54189-68f4-4355-9d71-4da0425f0803
node_exporter        Running          push                /agent_id/542b71fd-2122-4581-8a62-544052440838
vmagent              Running          push                /agent_id/3551cfde-0e88-4561-a5dd-3c4310acecbf

[root@ip-172-31-22-44 ~]# hostname -I
172.31.22.44

Finally in main Master server , i just kepted like this.... 
Note :- Here Service-name = Should give hostname / any name of Main [ Master ] MariaDB server [ i.e where you are running pmm-admin command you should give the hostname of that server ]

[root@ip-172-31-22-44 ~]# pmm-admin add mysql --query-source=perfschema --username=pmm --password=pmm --service-name=mariadb_main_server_master --host=172.31.22.44 --port=3306
MySQL Service added.
Service ID  : /service_id/1936f452-6b0f-427c-b68a-df7809138fe3
Service name: mariadb_main_server_master
Table statistics collection enabled (the limit is 1000, the actual table count is 159).

[root@ip-172-31-22-44 ~]# pmm-admin list
Service type        Service name                      Address and port         Service ID
MySQL               mariadb_main_server_master        172.31.22.44:3306        /service_id/1936f452-6b0f-427c-b68a-df7809138fe3

Agent type                    Status           Metrics Mode        Agent ID                                              Service ID
pmm_agent                     Connected                            /agent_id/0f43c776-fd89-4f39-a419-b184cdc6a436
node_exporter                 Running          push                /agent_id/7a7f6d08-4902-4c91-b107-a5ec629fec9e
mysqld_exporter               Running          push                /agent_id/44fc15cb-f742-4883-9473-b2ca5c9f3fc5        /service_id/1936f452-6b0f-427c-b68a-df7809138fe3
mysql_perfschema_agent        Running                              /agent_id/8fe4d5d1-0093-4456-b7f8-027d6a3af079        /service_id/1936f452-6b0f-427c-b68a-df7809138fe3
vmagent                       Running          push                /agent_id/f2834a31-dcb6-4b6f-a680-0db4cc9cb193

If i want one of the service which we configured above to delete , just login in to PMM , and go to Inventory / Services ==> Select which one you don't want , then run once again omm-admin list command in Main [ Master ] Server .

[root@ip-172-31-22-44 ~]# pmm-admin list
Service type        Service name                       Address and port         Service ID
MySQL               mariadb_main_server1_master        172.31.22.44:3306        /service_id/80e610f2-d5ef-49ee-a348-868b14b43aa4

Agent type                    Status           Metrics Mode        Agent ID                                              Service ID
pmm_agent                     Connected                            /agent_id/15a54189-68f4-4355-9d71-4da0425f0803
node_exporter                 Running          push                /agent_id/542b71fd-2122-4581-8a62-544052440838
mysqld_exporter               Running          push                /agent_id/f489f2b4-e480-4b11-b3c5-0a819906a165        /service_id/80e610f2-d5ef-49ee-      a348-868b14b43aa4
mysql_perfschema_agent        Running                              /agent_id/0186acab-2a48-441f-a81c-2c4369b02c7a        /service_id/80e610f2-d5ef-49ee-      a348-868b14b43aa4
vmagent                       Running          push                /agent_id/3551cfde-0e88-4561-a5dd-3c4310acecbf


[root@ip-172-31-22-44 ~]# pmm-admin add mysql --query-source=slowlog --username=pmm --password=pmm mariadb_main_server_master_slow_sql ========> This is slow query log report

MySQL Service added.
Service ID  : /service_id/3f4b86f9-b437-4104-9a48-6eb7094cd47f
Service name: mariadb_main_server_master_slow_sql

Table statistics collection enabled (the limit is 1000, the actual table count is 159).

[root@ip-172-31-22-44 ~]# pmm-admin list
Service type        Service name                               Address and port         Service ID
MySQL               mariadb_main_server_master                 172.31.22.44:3306        /service_id/1936f452-6b0f-427c-b68a-df7809138fe3
MySQL               mariadb_main_server_master_slow_sql        127.0.0.1:3306           /service_id/3f4b86f9-b437-4104-9a48-6eb7094cd47f

Agent type                    Status           Metrics Mode        Agent ID                                              Service ID
pmm_agent                     Connected                            /agent_id/0f43c776-fd89-4f39-a419-b184cdc6a436
node_exporter                 Running          push                /agent_id/7a7f6d08-4902-4c91-b107-a5ec629fec9e
mysqld_exporter               Running          push                /agent_id/3841edbe-5bad-4622-a4f6-bedd0caeda79        /service_id/3f4b86f9-b437-4104-9a48-6eb7094cd47f
mysqld_exporter               Running          push                /agent_id/44fc15cb-f742-4883-9473-b2ca5c9f3fc5        /service_id/1936f452-6b0f-427c-b68a-df7809138fe3
mysql_perfschema_agent        Running                              /agent_id/8fe4d5d1-0093-4456-b7f8-027d6a3af079        /service_id/1936f452-6b0f-427c-b68a-df7809138fe3
mysql_slowlog_agent           Waiting                              /agent_id/83a67171-e1df-4b3b-b5fa-10fee129a0c4        /service_id/3f4b86f9-b437-4104-9a48-6eb7094cd47f
vmagent                       Starting         push                /agent_id/f2834a31-dcb6-4b6f-a680-0db4cc9cb193

In Replica Server [ slave ] :-
---------------------------------

Note :- Here Service-name = Should give hostname / any name of replica [ slave ] MariaDB server [ i.e where you are running pmm-admin command you should give the hostname of that server ]

[root@ip-172-31-16-154 ~]# hostname -I
172.31.16.154

[root@ip-172-31-16-154 ~]# pmm-admin add mysql --query-source=perfschema --username=pmm --password=pmm --service-name=mariadb_replica_server_slave --host=172.31.16.154 --port=3306
MySQL Service added.
Service ID  : /service_id/4bbb6e97-2b12-4ef5-bb1d-264068726043
Service name: mariadb_replica_server_slave

Table statistics collection enabled (the limit is 1000, the actual table count is 159).

[root@ip-172-31-16-154 ~]# pmm-admin add mysql --query-source=slowlog --username=pmm --password=pmm mariadb_replica_server_slave_slow_sql
MySQL Service added.
Service ID  : /service_id/748b8452-5927-4a13-ac15-ed619f729d66
Service name: mariadb_replica_server_slave_slow_sql

Table statistics collection enabled (the limit is 1000, the actual table count is 159).

[root@ip-172-31-16-154 ~]# pmm-admin list
Service type        Service name                                 Address and port          Service ID
MySQL               mariadb_replica_server_slave                 172.31.16.154:3306        /service_id/4bbb6e97-2b12-4ef5-bb1d-264068726043
MySQL               mariadb_replica_server_slave_slow_sql        127.0.0.1:3306            /service_id/748b8452-5927-4a13-ac15-ed619f729d66

Agent type                    Status           Metrics Mode        Agent ID                                              Service ID
pmm_agent                     Connected                            /agent_id/f5bcc81b-129b-4b4c-ad0f-1ab304310b6e
node_exporter                 Running          push                /agent_id/215ffe75-e441-4c0e-8e9c-27296a0a5db7
mysqld_exporter               Running          push                /agent_id/6ca44e43-fe91-4cd9-8a8d-97f08b1f73a7        /service_id/748b8452-5927-4a13-a     c15-ed619f729d66
mysqld_exporter               Running          push                /agent_id/f19cb276-146e-4c8d-8f81-97cbefed3a91        /service_id/4bbb6e97-2b12-4ef5-b     b1d-264068726043
mysql_perfschema_agent        Running                              /agent_id/1d42cf29-8421-4caf-8487-63512c5ea4c0        /service_id/4bbb6e97-2b12-4ef5-b     b1d-264068726043
mysql_slowlog_agent           Waiting                              /agent_id/66871fbe-9f9f-497c-9ed8-fdb737f57275        /service_id/748b8452-5927-4a13-a     c15-ed619f729d66
vmagent                       Running          push                /agent_id/4897e3ae-a238-4e79-8035-ae223f324fa8



Status of pmm-admin for both servers [ Main and Replica ] Servers :-
---------------------------------------------------------------------

[root@ip-172-31-22-44 ~]# hostname -I
172.31.22.44

[root@ip-172-31-22-44 ~]# pmm-admin status
Agent ID: /agent_id/0f43c776-fd89-4f39-a419-b184cdc6a436
Node ID : /node_id/66744072-1e39-4865-b34c-7577c668633c

PMM Server:
        URL    : https://44.196.179.230:443/
        Version: 2.19.0

PMM Client:
        Connected        : true
        Time drift       : 369.518µs
        Latency          : 724.161µs
        pmm-admin version: 2.19.0
        pmm-agent version: 2.19.0
Agents:
        /agent_id/3841edbe-5bad-4622-a4f6-bedd0caeda79 mysqld_exporter Running
        /agent_id/44fc15cb-f742-4883-9473-b2ca5c9f3fc5 mysqld_exporter Running
        /agent_id/7a7f6d08-4902-4c91-b107-a5ec629fec9e node_exporter Running
        /agent_id/83a67171-e1df-4b3b-b5fa-10fee129a0c4 mysql_slowlog_agent Waiting
        /agent_id/8fe4d5d1-0093-4456-b7f8-027d6a3af079 mysql_perfschema_agent Running
        /agent_id/f2834a31-dcb6-4b6f-a680-0db4cc9cb193 vmagent Running

[root@ip-172-31-22-44 ~]#

[root@ip-172-31-16-154 ~]# hostname -I
172.31.16.154
[root@ip-172-31-16-154 ~]# pmm-admin status
Agent ID: /agent_id/31d09271-b426-465f-ab36-b4aaa4ff4a91
Node ID : /node_id/20917476-aa47-4a9c-b06d-f0c01b336017

PMM Server:
        URL    : https://44.196.179.230:443/
        Version: 2.19.0

PMM Client:
        Connected        : true
        Time drift       : 134.008µs
        Latency          : 515.208µs
        pmm-admin version: 2.19.0
        pmm-agent version: 2.19.0
Agents:
        /agent_id/0b3a5dda-0c5c-445e-85b2-79a127d9c296 vmagent Running
        /agent_id/0d5cf4e2-6903-4bf0-a3c1-1e761e01d29e mysqld_exporter Running
        /agent_id/3a894355-f5d0-472d-9cd9-e0be2242c3c0 node_exporter Running
        /agent_id/884e0e9b-765a-4be5-9749-f12aef64a1ed mysql_slowlog_agent Waiting
        /agent_id/b2f1cd7b-6df1-4686-af06-56bc71c799c4 mysql_perfschema_agent Running
        /agent_id/b582da1d-1df7-483d-864e-d0228a549048 mysqld_exporter Running

[root@ip-172-31-16-154 ~]#


Login With PMM And screen shots :-

https://44.196.179.230:443/

Or 
http://44.196.179.230/
This is my public IP Address of EC2 machine . If i give Private IP Address , it was not connecting .. so i given public IP Address and able to login

Login Credentials   admin / admin 

 

2nd Screen :-

 

Here you can give same user name and password for conformation.  i.e  admin / admin 



3rd Screen :- 

 

After added services , please login in to PMM tool and check the inventory of all services which we added manually through commands. 
Click on Configuration  PMM Inventory  Inventory List  Services

 
Checking the Nodes :- 
Click on Configuration  PMM Inventory  Inventory List  Nodes

 

Create Folder for preparing th customized Dashboards , then wigets 
---------------------------------------------------------------------

Here I am creating some name called ‘SFR’ in “ + “ symbol 

 

If we want to see created folder , we need to go to   symbol and click on Manage option. So I can see “SFR” Folder from below screen.

 

If you click on “SFR” folder , it will apper the below screen.

 

Once you click on “Create Dashboard” ,the below screen will be appear.

  

If you want to give Required Dashboard name , click on Setting option in top right side.


The below screen shot will give about Dashboard name and other information and click on “Save Dashboard” option .
 

Now if I go “SFR” folder I can see 3 Dashboards which I created .

Database_Summary
 					    Node_OS_Summay
                               Databae_Summary_1
 


Checking some Metrices from DB side whether it’s enabled or not for PMM Setup.


MariaDB [(none)]> show variables like '%performance%';
+--------------------------------------------------------+-------+
| Variable_name                                          | Value |
+--------------------------------------------------------+-------+
| performance_schema                                     | ON    |
| performance_schema_accounts_size                       | 100   |
| performance_schema_digests_size                        | 5000  |
| performance_schema_events_stages_history_long_size     | 1000  |
| performance_schema_events_stages_history_size          | 20    |
| performance_schema_events_statements_history_long_size | 1000  |
| performance_schema_events_statements_history_size      | 20    |
| performance_schema_events_waits_history_long_size      | 1000  |
| performance_schema_events_waits_history_size           | 20    |
| performance_schema_hosts_size                          | 100   |
| performance_schema_max_cond_classes                    | 80    |
| performance_schema_max_cond_instances                  | 1500  |
| performance_schema_max_digest_length                   | 1024  |
| performance_schema_max_file_classes                    | 50    |
| performance_schema_max_file_handles                    | 32768 |
| performance_schema_max_file_instances                  | 2500  |
| performance_schema_max_mutex_classes                   | 200   |
| performance_schema_max_mutex_instances                 | 5858  |
| performance_schema_max_rwlock_classes                  | 40    |
| performance_schema_max_rwlock_instances                | 3143  |
| performance_schema_max_socket_classes                  | 10    |
| performance_schema_max_socket_instances                | 300   |
| performance_schema_max_stage_classes                   | 160   |
| performance_schema_max_statement_classes               | 200   |
| performance_schema_max_table_handles                   | 2858  |
| performance_schema_max_table_instances                 | 667   |
| performance_schema_max_thread_classes                  | 50    |
| performance_schema_max_thread_instances                | 358   |
| performance_schema_session_connect_attrs_size          | 512   |
| performance_schema_setup_actors_size                   | 100   |
| performance_schema_setup_objects_size                  | 100   |
| performance_schema_users_size                          | 100   |
+--------------------------------------------------------+-------+
32 rows in set (0.001 sec)

MariaDB [(none)]> show variables like 'innodb_monitor%';
+--------------------------+-------+
| Variable_name            | Value |
+--------------------------+-------+
| innodb_monitor_disable   |       |
| innodb_monitor_enable    | all   |
| innodb_monitor_reset     |       |
| innodb_monitor_reset_all |       |
+--------------------------+-------+
4 rows in set (0.001 sec)

MariaDB [(none)]> use performance_schema;
Database changed

MariaDB [performance_schema]> select * from setup_instruments;
+--------------------------------------------------------------------------
| NAME                                                                                                  | ENABLED | TIMED |
+--------------------------------------------------------------------------
| wait/synch/mutex/sql/PAGE::lock                                                                       | NO      | NO    |
| wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_sync                                                           | NO      | NO    |
| wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_active                                                         | NO      | NO    |
| wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_pool                                                           | NO      | NO    |
| wait/synch/mutex/sql/TC_LOG_MMAP::LOCK_pending_checkpoint                                             | NO      | NO    |
| wait/synch/mutex/sql/LOCK_des_key_file                                                                | NO      | NO    |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_index                                                        | NO      | NO    |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_xid_list                                                     | NO      | NO    |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_binlog_background_thread                                     | NO      | NO    |
| wait/synch/mutex/sql/MYSQL_BIN_LOG::LOCK_binlog_end_pos                                               | NO      | NO    |
| wait/synch/mutex/sql/MYSQL_RELAY_LOG::LOCK_index                                                      | NO      | NO    |
| wait/synch/mutex/sql/MYSQL_RELAY_LOG::LOCK_binlog_end_pos                                             | NO      | NO    |
| wait/synch/mutex/sql/Delayed_insert::mutex                                                            | NO      | NO    |
| wait/synch/mutex/sql/hash_filo::lock                                                                  | NO      | NO    |
| wait/synch/mutex/sql/LOCK_active_mi                                                                   | NO      | NO    |
| wait/synch/mutex/sql/LOCK_connection_count                                                            | NO      | NO    |
| wait/synch/mutex/sql/LOCK_thread_id                                                                   | NO      | NO    |
| wait/synch/mutex/sql/LOCK_crypt                                                                       | NO      | NO    |
| wait/synch/mutex/sql/LOCK_delayed_create                                                              | NO      | NO    |
| wait/synch/mutex/sql/LOCK_delayed_insert                                                              | NO      | NO    |
| wait/synch/mutex/sql/LOCK_delayed_status                                                              | NO      | NO    |
| wait/synch/mutex/sql/LOCK_error_log                                                                   | NO      | NO    |
| wait/synch/mutex/sql/LOCK_gdl                                                                         | NO      | NO    |
| wait/synch/mutex/sql/LOCK_global_system_variables                                                     | NO      | NO    |
| wait/synch/mutex/sql/LOCK_manager                                                                     | NO      | NO    |
| wait/synch/mutex/sql/LOCK_prepared_stmt_count                                                         | NO      | NO    |
| wait/synch/mutex/sql/LOCK_rpl_status                                                                  | NO      | NO    |
| wait/synch/mutex/sql/LOCK_server_started                                                              | NO      | NO    |
| wait/synch/mutex/sql/LOCK_status                                                                      | NO      | NO    |
| wait/synch/mutex/sql/LOCK_show_status                                                                 | NO      | NO    |
| wait/synch/mutex/sql/LOCK_system_variables_hash                                                       | NO      | NO    |
| wait/synch/mutex/sql/LOCK_stats                                                                       | NO      | NO    |
| wait/synch/mutex/sql/LOCK_global_user_client_stats                                                    | NO      | NO    |
| wait/synch/mutex/sql/LOCK_global_table_stats                                                          | NO      | NO    |
| wait/synch/mutex/sql/LOCK_global_index_stats                                                          | NO      | NO    |
| wait/synch/mutex/sql/THD::LOCK_wakeup_ready                                                           | NO      | NO    |
| wait/synch/mutex/sql/wait_for_commit::LOCK_wait_commit                                                | NO      | NO    |
| wait/synch/mutex/sql/gtid_waiting::LOCK_gtid_waiting                                                  | NO      | NO    |
| wait/io/file/innodb/innodb_data_file                                                                  | YES     | YES   |
| 
….
…    
+--------------------------------------------------------------------------
706 rows in set (0.001 sec)

MariaDB [performance_schema]> select count(1) from setup_instruments;
+----------+
| count(1) |
+----------+
|      706 |
+----------+
1 row in set (0.000 sec)

MariaDB [performance_schema]> select count(1) from setup_consumers;
+----------+
| count(1) |
+----------+
|       12 |
+----------+
1 row in set (0.000 sec)

MariaDB [performance_schema]> select * from setup_consumers;
+--------------------------------+---------+
| NAME                           | ENABLED |
+--------------------------------+---------+
| events_stages_current          | NO      |
| events_stages_history          | NO      |
| events_stages_history_long     | NO      |
| events_statements_current      | YES     |
| events_statements_history      | NO      |
| events_statements_history_long | NO      |
| events_waits_current           | NO      |
| events_waits_history           | NO      |
| events_waits_history_long      | NO      |
| global_instrumentation         | YES     |
| thread_instrumentation         | YES     |
| statements_digest              | YES     |
+--------------------------------+---------+
12 rows in set (0.000 sec)

MariaDB [performance_schema]> show variables like 'slow_query%';
+---------------------+--------------------------+
| Variable_name       | Value                    |
+---------------------+--------------------------+
| slow_query_log      | OFF                      |  == Should be ON 
| slow_query_log_file | ip-172-31-22-44-slow.log |
+---------------------+--------------------------+
2 rows in set (0.001 sec)

MariaDB [performance_schema]> show variables like 'log_output%';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| log_output    | FILE  |
+---------------+-------+
1 row in set (0.001 sec)


PMM Docker connection Commands :-


In PMM Server :-
------------------

[root@ip-172-31-17-0 ~]# docker ps -a
CONTAINER ID   IMAGE                  COMMAND                CREATED      STATUS                       PORTS                                      NAMES
440e11f9237e   percona/pmm-server:2   "/opt/entrypoint.sh"   5 days ago   Up About an hour (healthy)   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   pmm-server
1f3c4b2703d1   percona/pmm-server:2   "/bin/true"            5 days ago   Created                                                                 pmm-data

[root@ip-172-31-17-0 ~]# docker exec -it pmm-server /bin/bash
[root@440e11f9237e opt]#
[root@440e11f9237e opt]# cd
[root@440e11f9237e ~]# clickhouse
Use one of the following commands:
clickhouse local [args]
clickhouse client [args]
clickhouse benchmark [args]
clickhouse server [args]
clickhouse performance-test [args]
clickhouse extract-from-config [args]
clickhouse compressor [args]
clickhouse format [args]
clickhouse copier [args]
clickhouse obfuscator [args]



[root@440e11f9237e ~]# clickhouse local
[root@440e11f9237e ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
overlay          25G  4.1G   21G  17% /
tmpfs            64M     0   64M   0% /dev
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
shm              64M   16K   64M   1% /dev/shm
/dev/xvda1       25G  4.1G   21G  17% /srv
tmpfs           2.0G     0  2.0G   0% /proc/acpi
tmpfs           2.0G     0  2.0G   0% /proc/scsi
tmpfs           2.0G     0  2.0G   0% /sys/firmware
[root@440e11f9237e ~]# cd /var/lib/

[root@440e11f9237e lib]# ls -ltr
drwxr-xr-x 2 root       root          6 Apr 11  2018 rpm-state
drwxr-xr-x 2 root       root          6 Apr 11  2018 misc
drwxr-xr-x 2 root       root          6 Apr 11  2018 games
drwxr-xr-x 2 nobody     nobody        6 Sep 25  2020 prometheus
drwxr-xr-x 2 root       root          6 Sep 30  2020 dbus
drwxr-xr-x 2 root       root          6 Sep 30  2020 initramfs
drwx------ 2 root       root          6 Nov 13  2020 machines
drwxr-xr-x 1 root       root       4096 Nov 13  2020 rpm
drwxr-xr-x 1 root       root         40 Feb  2 16:34 systemd
drwxr-xr-x 2 nobody     nobody        6 May 17 08:25 alertmanager
drwx------ 3 postgres   postgres     37 Jun 30 11:40 pgsql
drwxr-xr-x 1 root       root       4096 Jun 30 11:41 alternatives
drwxr-xr-x 3 root       root         21 Jun 30 11:41 cloud
drwx------ 2 clickhouse clickhouse    6 Jun 30 11:42 clickhouse
drwxr-xr-x 3 grafana    grafana      21 Jun 30 11:42 grafana
drwxr-xr-x 1 root       root         68 Jun 30 11:43 yum
drwxr-xr-x 1 root       root         30 Aug  3 13:17 logrotate
[root@440e11f9237e lib]# cd clickhouse/
[root@440e11f9237e clickhouse]# ls -ltr
total 0
[root@440e11f9237e clickhouse]# cd
[root@440e11f9237e ~]#

I have created the below names for Customize Dashboards .

(1)	SFR_DB_Prod_Server [ Which is belongs to OS Metrices ]
 
	CPU
	Memory
	Disk
	Network

(2)	SFR_MariaDB_Database_Instance_Summary [ Which is belongs to DB Matrices ]
	Connections
	Temporary Objects & Slow Queries
	Select Types & Sorts
	Table Locks & Questions
	Network
	Memory
	Command ,Handlers ,Processes
	Table Openings
	MySQL Table Defination Cache 

 

 

--- Database Summary ---

MySQL Questions
Temporary Objects
Table Open Cache
Table Definition cache

------- InnoDB --------

Innodb Transactions
Innodb Log IO
Innodb Bufferpool data
Innodb Check point Age
Innodb Log file usage
Transaction History
Innodb AHI usage
Innodb Contention OS waits

----- MySQL summary -----

MySQL client thread activity
Top command Counters

Now let’s create a repeated row:

https://grafana.com/blog/2020/06/09/learn-grafana-how-to-automatically-repeat-rows-and-panels-in-dynamic-dashboards/


--> Click Add panel, and then click Convert to row. The panels you created earlier are automatically assigned to the row you created.
--> Hover your cursor over the Row title and click the gear icon to open the Row Options.
--> In Title, enter $service.
--> In Repeat for, select the variable you want to repeat rows for. For this example, select service.
--> Click Update.
--> Select multiple services from the service drop-down menu. Grafana creates a row for each selected service, each within its own set of repeated panels.
--> Find the left-most panel in the top-most row and edit it.
--> In the text area for the Text panel, enter $instance and $service.
--> Save the dashboard and refresh the page.
