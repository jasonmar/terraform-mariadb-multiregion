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
ip=`hostname -i`
if [ "$ip" == "${mariadb0}" ]; then
  otherip="${mariadb1}"
else
  otherip="${mariadb0}"
fi
status_file="master_${idx}.txt"
other_status_file="master_$other_idx.txt"
gcs_root="gs://${config_bucket}/${cluster_name}"
collectd_conf="/opt/stackdriver/collectd/etc/collectd.d/mysql.conf"

# Install MariaDB
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password password ${pass}'
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password_again password ${pass}'
apt install -y mariadb-server mariadb-client galera-3 galera-arbitrator-3

service mysql stop

cat <<EOF > /etc/mysql/my.cnf
[client-server]
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mariadb.conf.d/

[mysqld]
server_id         = ${idx}
report_host       = $ip
log_bin           = /var/log/mysql/mariadb-bin
log_bin_index     = /var/log/mysql/mariadb-bin.index
relay_log         = /var/log/mysql/relay-bin
relay_log_index   = /var/log/mysql/relay-bin.index
auto_increment_increment = 5
auto_increment_offset    = 1
skip-networking          = 0
skip-bind-address

EOF

service mysql start

# Replication
mysql -uroot -p${pass} -Bse "create user 'replusr'@'%' identified by '${replpass}'; grant replication slave on *.* to 'replusr'@'%';"

if [ "${idx}" == "0" ]; then
    other_idx="1"
else
    other_idx="0"
fi

cd "/tmp"
mysql -uroot -p${pass} -Bse "show master status;" > "$status_file"
gsutil cp "$status_file" "$gcs_root/"
sleep 60s # wait for other node to write status

gsutil cp "$gcs_root/$other_status_file" .
logfile=`cat "$other_status_file" | awk '{print $1}'`
logpos=`cat "$other_status_file" | awk '{print $2}'`
mysql -uroot -p${pass} -Bse "STOP SLAVE; CHANGE MASTER TO MASTER_HOST='$otherip', MASTER_USER='replusr', MASTER_PASSWORD='${replpass}', MASTER_LOG_FILE='$logfile', MASTER_LOG_POS=$logpos; START SLAVE;"

# StackDriver Agent
curl -sSO "https://dl.google.com/cloudagents/install-monitoring-agent.sh"
bash install-monitoring-agent.sh
apt install -y libmysqlclient20

cat <<EOF>> $collectd_conf
LoadPlugin mysql
<Plugin "mysql">
EOF

for db in ${databases}; do
cat <<EOF>> $collectd_conf
    <Database "$db">
        Host "localhost"
        Port 3306
        User "root"
        Password "${pass}"
        MasterStats true
        SlaveStats true
    </Database>
EOF
done

cat <<EOF>> $collectd_conf
</Plugin>

EOF

sudo service stackdriver-agent restart

exit 0
