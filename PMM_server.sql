

M2P-DB-MONITORIING - 3.109.229.121 / 172.17.0.1
Infra account
AWS-infra key


NOTE : Need Elastic IP
NOTE : Install Docker on the desired FS
NOTE : Open Ports between server and client


Install Percona Monitoring and Management
----------------------------------------

(1) Requirements: Docker

yum install docker

service docker status
service docker start
service docker status

(2) Create data volume:
sudo  docker create -v /datadb/docker --name pmm-data percona/pmm-server:2 /bin/true

[root@ip-172-150-0-56 docker]# sudo  docker create -v /datadb/docker --name pmm-data percona/pmm-server:2 /bin/true
Unable to find image 'percona/pmm-server:2' locally
2: Pulling from percona/pmm-server
2d473b07cdd5: Pull complete
cb234533d813: Pull complete
Digest: sha256:ff0bb20cba0dbfcc8929dbbba0558bb01acc933ec593717727707dce083441b4
Status: Downloaded newer image for percona/pmm-server:2
25eecceb5f12de159613d6ddaf5aab873901b4a528eca8fc8b432d94cade34d0

docker ps -a
sudo docker run -d -p 80:80 -p 443:443 --volumes-from pmm-data --name pmm-server --restart always percona/pmm-server:2

[root@ip-172-150-0-56 docker]# sudo docker run -d -p 80:80 -p 443:443 --volumes-from pmm-data --name pmm-server --restart always percona/pmm-server:2
031c3f65266d718c151d5a8211b049c8ecbea8a687e019d1ba6c0fd6fd6f18ed
[root@ip-172-150-0-56 docker]#


http://3.109.229.121

Step 2: Install Client
-------------------------------


Step 3: Alters
-------------------------------

AWS SES smtp server credentials,

docker exec -it pmm-server /bin/bash


cd /etc/grafana
vi /etc/grafana/grafana.ini 


[smtp]
enabled = true
host = email-smtp.ap-south-1.amazonaws.com:587
user = AKIASVSAB7DL754WRQ2Y
password = BJOr628DGGPeD2hhrUVk3jZ0XgBuJP0652k2AJ/ILOFp
;cert_file =
;key_file =
skip_verify = true
from_address = m2p-siem@m2p.in
from_name = PMM
# EHLO identity in SMTP dialog (defaults to instance_name)
;ehlo_identity = dashboard.example.com

From ID: connect@m2p.in, yap-noreply@m2p.in, nagios-alert@m2p.in, firewall-alerts@m2p.in, m2p-siem@m2p.in


SMTP: email-smtp.ap-south-1.amazonaws.com
Port: 587
User Name: AKIASVSAB7DL754WRQ2Y
Passwd: BJOr628DGGPeD2hhrUVk3jZ0XgBuJP0652k2AJ/ILOFp

--STEP 4
save changes and exit from containers bash
--restart container
docker restart pmm-server

go to Grafana “login” page http://PMM.SERVER.IP/graph/login
click “Sign up”
enter another email and press “sign up” button
find email in your mail client


Change timezone in PMM-SERVER
-----------------------------
1. Check existing timezone inside Docker
    [root@031c3f65266d opt]# cat /etc/localtime
    TZif2UTCTZif2UTC
    UTC0

    [root@031c3f65266d opt]# date
    Tue Nov  7 12:41:18 UTC 2023


2. Remove the existing local timezone link and create with required timezone
    rm -rf /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Calcutta /etc/localtime

    [root@031c3f65266d opt]# date
    Tue Nov  7 18:26:55 IST 2023


3. Change the time-zone inside postgres and restart

    postgres=# show timezone;
    TimeZone
    ----------
    UTC
    (1 row)

    [root@031c3f65266d opt]# grep timezone /srv/postgres14/postgresql.conf
    log_timezone = 'Asia/Calcutta'
    timezone = 'Asia/Calcutta'

    docker exec -it pmm-server supervisorctl restart postgresql

    postgres=# show timezone;
    TimeZone
    ---------------
    Asia/Calcutta
    (1 row)

