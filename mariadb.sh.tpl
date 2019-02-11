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
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/debian stretch main'
apt update -y

export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password password ${pass}'
debconf-set-selections <<< 'mariadb-server-10.3 mysql-server/root_password_again password ${pass}'

apt install -y mariadb-server mariadb-client galera-3 galera-arbitrator-3

service mariadb-server stop

cat <<EOF > /etc/mariadb/mariadb.conf
${mariadb0}
${mariadb1}
${pass}
EOF


cat <<EOF > /etc/logrotate.d/mariadb
/var/log/mariadb/*log {
  weekly
  rotate 150
  dateext
  compress
  copytruncate
  missingok 
}

EOF

sudo service mariadb-server restart

exit 0
