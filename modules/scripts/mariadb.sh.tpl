#!/bin/bash
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -x

apt install -y software-properties-common dirmngr
apt-key adv --recv-keys --no-tty --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/debian stretch main'
apt update -y

export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password password ${pass}'
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password_again password ${pass}'

apt install -y mariadb-server mariadb-client galera-3 galera-arbitrator-3

service mysql stop

cat <<EOF > /etc/mysql/mariadb.conf
${mariadb0}
${mariadb1}
${pass}
EOF

IP=`hostname -i`
SERVER=`echo $IP | cut -d . -f 4`
MY_HOST=`hostname | cut -c8`
x=`hostname | cut -c10`
get_file=0
echo $x
if [ $((x)) = 0 ]; then
    get_file=${mariadb1}
else
    get_file=${mariadb0}
fi
echo $get_file

getIP=`echo $get_file | cut -d . -f 4`

cat <<EOF > /etc/mysql/my.cnf
[client-server]

# Import all .cnf files from configuration directory
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/
# bind-address          = 127.0.0.1
[mysqld]
server_id               = $SERVER
report_host             = $IP
log_bin                 = /var/log/mysql/mariadb-bin
log_bin_index           = /var/log/mysql/mariadb-bin.index
relay_log               = /var/log/mysql/relay-bin
relay_log_index         = /var/log/mysql/relay-bin.index
# replicate-do-db       = testdb
auto_increment_increment = 5
auto_increment_offset = 1
skip-networking=0
skip-bind-address

EOF

service mysql start

mysql -uroot -p${pass} -Bse "create user 'replusr'@'%' identified by 'replusr';
grant replication slave on *.* to 'replusr'@'%';"

mysql -uroot -p${pass} -Bse "show master status;" > ~/master_$SERVER.txt

gsutil mv ~/master_$SERVER.txt gs://${config_bucket}/

sleep 60s

gsutil cp gs://${config_bucket}/master_$getIP.txt ~/

LOG_FILE=`cat ~/master_$getIP.txt | awk '{print $1}'`
LOG_POS=`cat ~/master_$getIP.txt | awk '{print $2}'`

mysql -uroot -p${pass} -Bse "STOP SLAVE;
CHANGE MASTER TO MASTER_HOST='10.0.1.$getIP', MASTER_USER='replusr', MASTER_PASSWORD='replusr', MASTER_LOG_FILE='$LOG_FILE', MASTER_LOG_POS=$LOG_POS;
START SLAVE;"

exit 0
